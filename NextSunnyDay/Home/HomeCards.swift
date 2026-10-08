import SunnyDay
import SwiftUI
import Weather

/// The next 24 hours, starting with the current one. The first hour of a day shows its date.
struct NextHoursCard: View {
  let hours: [HourForecast]
  @ScaledMetric private var cellWidth: CGFloat = 56
  @ScaledMetric private var symbolHeight: CGFloat = 28
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  private var shownHours: [HourForecast] {
    let thisHour = Calendar.current.dateInterval(of: .hour, for: .now)?.start ?? .now
    return Array(hours.filter { $0.date >= thisHour }.prefix(24))
  }

  var body: some View {
    CardSection(title: "Hourly Forecast") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 0) {
          ForEach(Array(shownHours.enumerated()), id: \.element.date) { index, hour in
            VStack(spacing: 8) {
              Group {
                if index == 0 {
                  Text("Now")
                } else if Calendar.current.component(.hour, from: hour.date) == 0 {
                  Text(verbatim: hour.date.monthDay).fontWeight(.semibold)
                } else {
                  Text(verbatim: hour.date.hour)
                }
              }
              .font(.footnote)
              .foregroundStyle(.secondary)
              WeatherSymbol(name: hour.symbolName)
                .font(.title2)
                .frame(height: symbolHeight)
              Text(
                verbatim: hour.precipitationChance.isShownAsPrecipitation
                  ? hour.precipitationChance.percent : " "
              )
              .font(.caption2.weight(.semibold))
              .foregroundStyle(.cyan)
              Text(verbatim: hour.temperature.degrees(in: temperatureUnit))
            }
            .frame(width: cellWidth)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: spokenHour(hour, isNow: index == 0)))
          }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
      }
    }
  }

  /// What VoiceOver says for a cell, with the condition the symbol shows.
  private func spokenHour(_ hour: HourForecast, isNow: Bool) -> String {
    let time =
      if isNow {
        String(localized: "Now")
      } else if Calendar.current.component(.hour, from: hour.date) == 0 {
        "\(hour.date.dayWithWeekday) \(hour.date.hour)"
      } else {
        hour.date.hour
      }
    var parts = [time, hour.condition.localizedName]
    if hour.precipitationChance.isShownAsPrecipitation {
      parts.append(String(localized: "Chance of rain \(hour.precipitationChance.percent)"))
    }
    parts.append(hour.temperature.degrees(in: temperatureUnit))
    return parts.joined(separator: ", ")
  }
}

/// Ten days; a row opens the day detail screen.
struct DaysCard: View {
  let days: [DayForecast]
  let level: SunnyLevel

  var body: some View {
    CardSection(title: "10-Day Forecast") {
      VStack(spacing: 0) {
        ForEach(Array(days.enumerated()), id: \.element.date) { index, day in
          NavigationLink(value: HomeRoute.day(index)) {
            DayRow(day: day, isToday: index == 0, isSunny: level.counts(day))
          }
          .buttonStyle(.plain)
          if index != days.count - 1 {
            Divider().padding(.leading, 66)
          }
        }
      }
      .padding(.vertical, 4)
    }
  }
}

struct DayRow: View {
  let day: DayForecast
  let isToday: Bool
  let isSunny: Bool
  @ScaledMetric private var symbolWidth: CGFloat = 36
  @ScaledMetric private var symbolHeight: CGFloat = 28
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  var body: some View {
    HStack(spacing: 14) {
      VStack(spacing: 2) {
        WeatherSymbol(name: day.symbolName)
          .font(.title2)
          .frame(height: symbolHeight)
        if day.precipitationChance.isShownAsPrecipitation {
          Text(verbatim: day.precipitationChance.percent)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.cyan)
            .accessibilityLabel(Text("Chance of rain \(day.precipitationChance.percent)"))
        }
      }
      .frame(width: symbolWidth)
      // At accessibility sizes the temperatures go under the day, which needs the whole width.
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: 2) {
          titles
          temperatures
        }
        Spacer(minLength: 8)
      } else {
        titles
        Spacer(minLength: 8)
        temperatures
      }
      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.tertiary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .contentShape(Rectangle())
  }

  private var titles: some View {
    VStack(alignment: .leading, spacing: 2) {
      if isToday { Text("Today") } else { Text(verbatim: day.date.dayWithWeekday) }
      Text(verbatim: day.condition.localizedName)
        .font(.subheadline)
        .foregroundStyle(isSunny ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
    }
  }

  private var temperatures: some View {
    HStack(spacing: 6) {
      Text(verbatim: day.highTemperature.degrees(in: temperatureUnit))
      Text(verbatim: day.lowTemperature.degrees(in: temperatureUnit)).foregroundStyle(.secondary)
    }
    .font(.body.monospacedDigit())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      Text(
        "High \(day.highTemperature.degrees(in: temperatureUnit)) Low \(day.lowTemperature.degrees(in: temperatureUnit))"
      ))
  }
}

/// Shown above the cached forecast when a refresh failed.
struct RefreshFailedBanner: View {
  let fetchedAt: Date
  let retry: () -> Void
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    // At accessibility sizes the button goes under the text, which needs the whole width.
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
      : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
    layout {
      Image(systemName: "exclamationmark.icloud.fill")
        .font(.title2)
        .foregroundStyle(.red)
      VStack(alignment: .leading, spacing: 2) {
        Text("Couldn't update the weather")
          .font(.headline)
        Text("Showing the forecast from \(fetchedAt.fetchTime)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 0)
      Button("Retry", action: retry)
        .buttonStyle(.glass)
        .controlSize(.small)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(
      Color(.secondarySystemGroupedBackground),
      in: RoundedRectangle(cornerRadius: 26, style: .continuous))
  }
}

/// Why there is no forecast to show.
struct NoDataCard: View {
  let failure: RegionForecast.Failure
  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      switch failure {
      case .fetch:
        Label("Try again where you have a connection", systemImage: "wifi.exclamationmark")
          .font(.headline)
        Text(
          "The app couldn't connect to the internet or get the weather from Apple Weather. Wait a moment, or pull down on the screen to update."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
      case .locationDenied:
        Label("Location access is off", systemImage: "location.slash.fill")
          .font(.headline)
        Text("Allow location access in Settings, or search for a region instead.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Button("Open Settings") {
          if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
        }
        .buttonStyle(.glass)
        .padding(.top, 4)
      case .locationUnavailable:
        Label("Couldn't find where you are", systemImage: "location.slash.fill")
          .font(.headline)
        Text("Try again in a moment, or search for a region instead.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      Color(.secondarySystemGroupedBackground),
      in: RoundedRectangle(cornerRadius: 26, style: .continuous))
  }
}

/// The cards in gray while the first forecast loads.
struct LoadingPlaceholder: View {
  var body: some View {
    Group {
      CardSection(title: "Hourly Forecast") {
        HStack(spacing: 0) {
          ForEach(0..<6, id: \.self) { _ in
            VStack(spacing: 8) {
              Text(verbatim: "00").font(.footnote)
              Image(systemName: "cloud.fill").font(.title2).frame(height: 28)
              Text(verbatim: "00%").font(.caption2)
              Text(verbatim: "00°")
            }
            .frame(width: 56)
          }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
      }
      CardSection(title: "10-Day Forecast") {
        VStack(spacing: 0) {
          ForEach(0..<6, id: \.self) { index in
            HStack(spacing: 14) {
              Image(systemName: "cloud.fill").font(.title2).frame(height: 28)
                .frame(width: 36)
              VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "October 00 (Sat)")
                Text(verbatim: "Clear").font(.subheadline)
              }
              Spacer(minLength: 8)
              Text(verbatim: "00° 00°")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            if index != 5 {
              Divider().padding(.leading, 66)
            }
          }
        }
        .padding(.vertical, 4)
      }
    }
    .redacted(reason: .placeholder)
    .accessibilityHidden(true)
  }
}
