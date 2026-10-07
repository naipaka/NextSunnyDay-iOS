//
//  NextSunnyDayWidget.swift
//  NextSunnyDayWidget
//
//  Created by rMac on 2020/10/19.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  /// Fetch again once the earliest stored day started more than this long ago.
  private static let maxForecastAge: TimeInterval = 60 * 60 * 20

  private let weatherProvider: WeatherProviding = WeatherKitProvider()
  private let settings = SettingsStore()
  private let cache: ForecastCaching = ForecastCache()

  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), forecast: .sample())
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    Task {
      completion(SimpleEntry(date: Date(), forecast: await cachedForecast()))
    }
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    Task {
      let currentDate = Date()
      var forecast = await cachedForecast()

      // The current location is resolved with Core Location in #95/#96; until then the widget
      // only refreshes a searched place.
      if let region = settings.regions.first, let location = region.location,
        forecast?.needsRefresh(for: location, now: currentDate, maxAge: Self.maxForecastAge)
          ?? true,
        let fetched = try? await weatherProvider.forecast(for: location)
      {
        try? await cache.save(fetched, for: region.id)
        forecast = fetched
      }

      let nextUpdate = currentDate.addingTimeInterval(5 * 60 * 60)
      completion(
        Timeline(
          entries: [SimpleEntry(date: currentDate, forecast: forecast)], policy: .after(nextUpdate)
        ))
    }
  }

  /// The cached forecast of the region shown, which is the only one for now.
  private func cachedForecast() async -> ForecastSnapshot? {
    guard let region = settings.regions.first, let cached = await cache.load(for: region.id),
      region.matches(cached)
    else { return nil }
    return cached
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let forecast: ForecastSnapshot?
}

struct NextSunnyDayWidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      if entry.forecast?.daily.isEmpty ?? true {
        NextSunnyDaySmallView(viewModel: NextSunnyDayViewModel(.sample()))
          .redacted(reason: .placeholder)
      } else {
        NextSunnyDaySmallView(viewModel: NextSunnyDayViewModel(entry.forecast))
      }
    default:
      if entry.forecast?.daily.isEmpty ?? true {
        NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(.sample()))
          .redacted(reason: .placeholder)
      } else {
        NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(entry.forecast))
      }
    }
  }
}

@main
struct NextSunnyDayWidget: Widget {
  let kind: String = "NextSunnyDayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      NextSunnyDayWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("NextSunnyDay")
    .description("See when the next sunny day is.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct NextSunnyDayWidget_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NextSunnyDayWidgetEntryView(
        entry: SimpleEntry(date: Date(), forecast: nil)
      )
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      NextSunnyDayWidgetEntryView(
        entry: SimpleEntry(date: Date(), forecast: nil)
      )
      .previewContext(WidgetPreviewContext(family: .systemMedium))
      NextSunnyDayWidgetEntryView(entry: SimpleEntry(date: Date(), forecast: .sample()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      NextSunnyDayWidgetEntryView(entry: SimpleEntry(date: Date(), forecast: .sample()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
