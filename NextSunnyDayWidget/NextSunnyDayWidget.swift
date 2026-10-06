//
//  NextSunnyDayWidget.swift
//  NextSunnyDayWidget
//
//  Created by rMac on 2020/10/19.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  private let weatherProvider: WeatherProviding = WeatherKitProvider()

  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), entity: .defaultEntity)
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    let results = DailyWeatherForecastEntity.all()
    let entity = results.first ?? DailyWeatherForecastEntity()
    let entry = SimpleEntry(date: Date(), entity: entity)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let currentDate = Date()
    let results = DailyWeatherForecastEntity.all()
    let entity = results.first ?? DailyWeatherForecastEntity()

    guard let entryDate = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate) else {
      return
    }
    let timeline = Timeline(
      entries: [SimpleEntry(date: currentDate, entity: entity)], policy: .after(entryDate))

    let latestDate = entity.daily.min(by: { $0.date < $1.date })?.date ?? 0
    if !entity.cityName.isEmpty
      && latestDate + 60 * 60 * 20 < Int(currentDate.timeIntervalSince1970)
    {
      let location = entity.location
      Task { @MainActor in
        if let forecasts = try? await weatherProvider.dailyForecast(for: location) {
          DailyWeatherForecastEntity.update(
            with: DailyWeatherForecastEntity(location: location, forecasts: forecasts))
        }
        completion(timeline)
      }
    } else {
      completion(timeline)
    }
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let entity: DailyWeatherForecastEntity
}

struct NextSunnyDayWidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      if entry.entity.daily.isEmpty {
        NextSunnyDaySmallView(viewModel: NextSunnyDayViewModel(placeholderEntity))
          .redacted(reason: .placeholder)
      } else {
        NextSunnyDaySmallView(viewModel: NextSunnyDayViewModel(entry.entity))
      }
    default:
      if entry.entity.daily.isEmpty {
        NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(placeholderEntity))
          .redacted(reason: .placeholder)
      } else {
        NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(entry.entity))
      }
    }
  }
}

extension NextSunnyDayWidgetEntryView {
  private var placeholderEntity: DailyWeatherForecastEntity {
    DailyWeatherForecastEntity(
      location: ForecastLocation(name: "", latitude: 0, longitude: 0),
      forecasts: [.sample(date: Date(), condition: .clear)]
    )
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
        entry: SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity())
      )
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      NextSunnyDayWidgetEntryView(
        entry: SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity())
      )
      .previewContext(WidgetPreviewContext(family: .systemMedium))
      NextSunnyDayWidgetEntryView(entry: SimpleEntry(date: Date(), entity: .defaultEntity))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      NextSunnyDayWidgetEntryView(entry: SimpleEntry(date: Date(), entity: .defaultEntity))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
