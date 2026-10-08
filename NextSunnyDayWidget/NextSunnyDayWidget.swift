import CoreLocation
import Forecast
import Region
import SunnyDay
import SwiftUI
import Weather
import WidgetKit

/// Reads the region and its cached forecast from the App Group, and fetches when the forecast is
/// stale. The widget doesn't use Core Location: for the current location it fetches for the
/// coordinate of the last cached forecast (ADR 0003). Its schedule is decided in #96.
struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SunnyEntry {
    SunnyEntry(date: .now, placeName: nil, forecast: nil, level: .default)
  }

  func getSnapshot(in context: Context, completion: @escaping @Sendable (SunnyEntry) -> Void) {
    Task {
      completion(await entry(fetchingIfStale: false))
    }
  }

  func getTimeline(
    in context: Context, completion: @escaping @Sendable (Timeline<SunnyEntry>) -> Void
  ) {
    Task {
      let entry = await entry(fetchingIfStale: true)
      completion(
        Timeline(entries: [entry], policy: .after(entry.date.addingTimeInterval(5 * 60 * 60))))
    }
  }

  private func entry(fetchingIfStale: Bool) async -> SunnyEntry {
    let level = SunnyLevelStore().load()
    guard let region = RegionStore().load().first else {
      return SunnyEntry(date: .now, placeName: nil, forecast: nil, level: level)
    }
    let updater = ForecastUpdater()
    var cached = await updater.cached(regionID: region.id)
    if fetchingIfStale, cached.map({ !updater.isFresh($0) }) ?? true,
      let coordinate = region.coordinate ?? cached?.coordinate,
      let fetched = try? await updater.fetch(
        regionID: region.id, placeName: region.placeName ?? cached?.placeName,
        coordinate: coordinate)
    {
      cached = fetched
    }
    return SunnyEntry(
      date: .now, placeName: region.placeName ?? cached?.placeName,
      forecast: cached?.forecast, level: level)
  }
}

struct SunnyEntry: TimelineEntry {
  let date: Date
  let placeName: String?
  let forecast: WeatherForecast?
  let level: SunnyLevel

  var nextSunnyDay: NextSunnyDay? {
    forecast.flatMap { level.nextSunnyDay(in: $0.daily, now: date) }
  }
}

struct NextSunnyDayWidgetEntryView: View {
  var entry: SunnyEntry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        Text("Next Sunny Day")
          .font(.caption.weight(.semibold))
        Spacer()
        Image(systemName: entry.nextSunnyDay == nil ? "cloud.fill" : "sun.max.fill")
          .font(.title3)
      }
      Spacer()
      headline
        .font(.system(size: family == .systemSmall ? 30 : 34, weight: .bold))
        .minimumScaleFactor(0.6)
        .lineLimit(1)
      if let next = entry.nextSunnyDay {
        Text(
          verbatim:
            "\(next.day.date.formatted(.dateTime.month(.defaultDigits).day().weekday(.abbreviated))) \(next.day.condition.localizedName)"
        )
        .font(.caption.weight(.semibold))
      }
      if let placeName = entry.placeName {
        Text(verbatim: placeName)
          .font(.caption2)
          .opacity(0.85)
      }
    }
    .foregroundStyle(.white)
    .redacted(reason: entry.forecast == nil ? .placeholder : [])
  }

  @ViewBuilder private var headline: some View {
    if let next = entry.nextSunnyDay {
      switch next.daysAway {
      case 0: Text("Today")
      case 1: Text("Tomorrow")
      default: Text("In \(next.daysAway) days")
      }
    } else {
      Text("Maybe not for a while")
    }
  }
}

@main
struct NextSunnyDayWidget: Widget {
  let kind: String = "NextSunnyDayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      NextSunnyDayWidgetEntryView(entry: entry)
        .containerBackground(for: .widget) {
          entry.nextSunnyDay == nil ? Color(.systemGray) : Color.orange
        }
    }
    .configurationDisplayName("NextSunnyDay")
    .description("See when the next sunny day is.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

extension SavedRegion {
  /// The coordinate of a searched place; `nil` for the current location.
  fileprivate var coordinate: CLLocationCoordinate2D? {
    if case .place(_, let latitude, let longitude) = kind {
      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    } else {
      nil
    }
  }
}
