import Forecast
import Region
import SunnyDay
import SwiftUI
import Weather

/// The one screen: when the next sunny day is in the shown region, today, the days after it and
/// the attribution, on the orange or gray of the answer. Fetches like the iPhone's Home.
struct SunnyDayView: View {
  /// What the answer says.
  enum State {
    case loading
    case noData(WatchForecast.Failure?)
    case sunny(NextSunnyDay)
    case noneInRange
  }

  @Environment(SyncedSettings.self) private var settings
  @Environment(WatchForecast.self) private var forecast
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorSchemeContrast) private var contrast
  @SwiftUI.State private var now = Date.now
  @SwiftUI.State private var isPickingRegion = false

  /// When the region, the app being active or the day changes, fetch if stale.
  private struct RefreshKey: Equatable {
    var region: SavedRegion?
    var isActive: Bool
    var day: Date
  }

  var body: some View {
    NavigationStack {
      Group {
        if let region = settings.region {
          ScrollView {
            content(region)
              .scenePadding(.horizontal)
          }
        } else {
          NoRegionView()
        }
      }
      .containerBackground(tone.fill(increasedContrast: contrast == .increased), for: .navigation)
      .navigationTitle(Text(verbatim: title))
      .toolbarForegroundStyle(.white, for: .navigationBar)
      .toolbar {
        if settings.regions.count > 1 {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              isPickingRegion = true
            } label: {
              Label("Regions", systemImage: "list.bullet")
            }
          }
        }
      }
      .sheet(isPresented: $isPickingRegion) {
        RegionPicker()
      }
    }
    .task(id: refreshKey) {
      guard scenePhase == .active, let region = settings.region else { return }
      await forecast.refreshIfNeeded(for: region)
    }
    .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
      now = .now
    }
    .onChange(of: scenePhase) {
      now = .now
    }
  }

  private func content(_ region: SavedRegion) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      AnswerView(state: state, level: settings.level, unit: settings.unit) {
        Task { await forecast.refresh(for: region) }
      }
      if let today {
        Line().padding(.vertical, 10)
        TodayRow(day: today, unit: settings.unit)
      }
      if !laterDays.isEmpty {
        Line().padding(.vertical, 10)
        VStack(spacing: 4) {
          ForEach(laterDays, id: \.date) { day in
            DayRow(day: day, isSunny: settings.level.counts(day), unit: settings.unit)
          }
        }
      }
      if hasCachedDays, forecast.failure != nil {
        UpdateFailedRow {
          Task { await forecast.refresh(for: region) }
        }
        .padding(.top, 12)
      }
      AttributionFooter(fetchedAt: hasCachedDays ? forecast.forecast?.fetchedAt : nil)
        .padding(.top, 16)
    }
    .foregroundStyle(.white)
  }

  // MARK: - What the screen shows

  private var refreshKey: RefreshKey {
    RefreshKey(
      region: settings.region, isActive: scenePhase == .active,
      day: Calendar.current.startOfDay(for: now))
  }

  /// The cached days from today on, for the shown region.
  private var days: [DayForecast] {
    guard let cached = forecast.forecast, cached.regionID == settings.region?.id else { return [] }
    return cached.forecast.days(from: now)
  }

  private var hasCachedDays: Bool { !days.isEmpty }

  private var today: DayForecast? {
    days.first.flatMap { Calendar.current.isDate($0.date, inSameDayAs: now) ? $0 : nil }
  }

  private var laterDays: [DayForecast] {
    days.filter { !Calendar.current.isDate($0.date, inSameDayAs: now) }
  }

  private var state: State {
    guard hasCachedDays else {
      return forecast.isLoading ? .loading : .noData(forecast.failure)
    }
    return settings.level.nextSunnyDay(in: days, now: now).map(State.sunny) ?? .noneInRange
  }

  private var tone: HeaderTone {
    guard settings.region != nil else { return .noData }
    return switch state {
    case .sunny: .sunny
    case .noneInRange: .gray
    case .loading, .noData: .noData
    }
  }

  /// The place's name, or for the current location where it was last found.
  private var title: String {
    guard let region = settings.region else { return "" }
    return region.placeName ?? forecast.forecast?.placeName
      ?? String(localized: "Current Location")
  }
}

/// 「次の晴れ」, 「あと3日」 and the day with its weather, or why there is no answer.
private struct AnswerView: View {
  let state: SunnyDayView.State
  let level: SunnyLevel
  let unit: UnitTemperature
  let retry: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(level.answerTitle)
        .font(.footnote.weight(.semibold))
      switch state {
      case .loading:
        HStack(spacing: 8) {
          ProgressView()
            .tint(.white)
            .fixedSize()
          Text("Getting the weather…")
            .font(.headline)
        }
        .padding(.vertical, 8)
      case .noData(let failure):
        bigText(Text("In ? days"))
        Text(failureText(failure))
          .font(.headline)
        RetryButton(action: retry)
          .padding(.top, 8)
      case .sunny(let next):
        bigText(next.daysAway == 1 ? Text("Tomorrow") : Text("In \(next.daysAway) days"))
        Label {
          Text(
            verbatim: "\(next.day.date.monthDayWeekday) \(next.day.condition.localizedName)")
        } icon: {
          WeatherSymbol(name: next.day.symbolName)
        }
        .font(.headline)
        Text(
          "High \(next.day.highTemperature.degrees(in: unit)) Low \(next.day.lowTemperature.degrees(in: unit))"
        )
        .font(.footnote)
      case .noneInRange:
        bigText(Text("Maybe not for a while"))
        Text(level.noneInRangeText)
          .font(.headline)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func bigText(_ text: Text) -> some View {
    text
      .font(.system(size: 40, weight: .bold))
      .lineLimit(1)
      .minimumScaleFactor(0.5)
  }

  private func failureText(_ failure: WatchForecast.Failure?) -> LocalizedStringResource {
    switch failure {
    case .locationDenied: "Location access is off"
    case .locationUnavailable: "Couldn't find where you are"
    case .fetch, nil: "Couldn't get the weather"
    }
  }
}

/// 「今日」 with today's weather and its high and low.
private struct TodayRow: View {
  let day: DayForecast
  let unit: UnitTemperature

  var body: some View {
    HStack(spacing: 6) {
      Text("Today")
        .font(.footnote.weight(.semibold))
      Spacer(minLength: 4)
      WeatherSymbol(name: day.symbolName)
      Text(verbatim: day.condition.localizedName)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .font(.headline)
    .accessibilityElement(children: .combine)
  }
}

/// A day after today: its date, weather and high and low. Days that count are bold on a light
/// band, as in the iPhone's large widget.
private struct DayRow: View {
  let day: DayForecast
  let isSunny: Bool
  let unit: UnitTemperature

  var body: some View {
    HStack(spacing: 6) {
      Text(verbatim: day.date.dayAndWeekday)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
      WeatherSymbol(name: day.symbolName)
        .frame(width: 24)
      Text(verbatim: day.highTemperature.degrees(in: unit))
        .frame(width: 30, alignment: .trailing)
      Text(verbatim: day.lowTemperature.degrees(in: unit))
        .opacity(0.75)
        .frame(width: 30, alignment: .trailing)
    }
    .font(.body.weight(isSunny ? .bold : .regular))
    .monospacedDigit()
    .padding(.horizontal, 6)
    .padding(.vertical, 3)
    .background {
      if isSunny {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.white.opacity(0.2))
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      Text(
        verbatim:
          "\(day.date.dayAndWeekday) \(day.condition.localizedName) \(day.highTemperature.degrees(in: unit)) \(day.lowTemperature.degrees(in: unit))"
      ))
  }
}

/// Shown under a cached forecast when the last fetch failed.
private struct UpdateFailedRow: View {
  let retry: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Couldn't update the weather")
        .font(.footnote)
      RetryButton(action: retry)
    }
  }
}

/// 「もう一度試す」 in white with black text, as on the iPhone's Home.
private struct RetryButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Try Again", systemImage: "arrow.clockwise")
        .foregroundStyle(.black)
    }
    .buttonStyle(.glassProminent)
    .tint(.white)
  }
}

/// A 1 pt white line at 40 %, as in the iPhone's header and widgets.
private struct Line: View {
  var body: some View {
    Rectangle()
      .fill(.white.opacity(0.4))
      .frame(height: 1)
  }
}

/// Before the iPhone sent a region.
private struct NoRegionView: View {
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "iphone")
        .font(.title)
      Text("Choose a region in the app on your iPhone.")
        .multilineTextAlignment(.center)
    }
    .foregroundStyle(.white)
  }
}

/// A weather symbol in its filled variant with the symbol's own colors, as the system's weather
/// app draws them on the watch.
struct WeatherSymbol: View {
  let name: String

  var body: some View {
    Image(systemName: name.filledSymbol)
      .symbolRenderingMode(.multicolor)
      .accessibilityHidden(true)
  }
}

#Preview("Sunny") {
  WatchPreviewHost(.tokyo)
}

#Preview("Laundry") {
  WatchPreviewHost(.laundry)
}

#Preview("None in range") {
  WatchPreviewHost(.singapore)
}

#Preview("Several regions") {
  WatchPreviewHost(.severalRegions)
}

#Preview("Loading") {
  WatchPreviewHost(.loading)
}

#Preview("Refresh failed") {
  WatchPreviewHost(.refreshFailed)
}

#Preview("Offline") {
  WatchPreviewHost(.offline)
}

#Preview("Location denied") {
  WatchPreviewHost(.locationDenied)
}

#Preview("No region") {
  WatchPreviewHost(.noRegion)
}
