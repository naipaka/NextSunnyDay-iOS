//
//  NextSunnyDayWidget.swift
//  NextSunnyDayWidget
//
//  Created by rMac on 2020/10/19.
//

import WidgetKit
import SwiftUI
import Combine

private var cancellables = Set<AnyCancellable>()

struct Provider: TimelineProvider {
    private let weatherFetcher = WeatherFetcher()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity.defaultEntity())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let results = DailyWeatherForecastEntity.all()
        let entity = results.first ?? DailyWeatherForecastEntity()
        let entry = SimpleEntry(date: Date(), entity: entity)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let results = DailyWeatherForecastEntity.all()
        let entity = results.first ?? DailyWeatherForecastEntity()

        guard let entryDate = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate) else { return }
        let timeline = Timeline(entries: [SimpleEntry(date: currentDate, entity: entity)], policy: .after(entryDate))

        let latestDate = entity.daily.min(by: { $0.date < $1.date })?.date ?? 0
        if !entity.cityName.isEmpty && latestDate + 60 * 60 * 24 < Int(currentDate.timeIntervalSince1970) {
            weatherFetcher.weeklyWeatherForecast(forLat: entity.lat, forLon: entity.lon)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion:  { value in
                        switch value {
                        case .failure:
                            completion(timeline)
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { forecast in
                        DailyWeatherForecastEntity.update(with: DailyWeatherForecastEntity.generateEntity(cityName: entity.cityName, forecast: forecast))
                        completion(timeline)
                    }
                )
                .store(in: &cancellables)
        } else {
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let entity: DailyWeatherForecastEntity
}

struct NextSunnyDayWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            NextSunnyDaySmallView(viewModel: NextSunnyDayViewModel(entry.entity))
        default:
            NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(entry.entity))
        }
    }
}

@main
struct NextSunnyDayWidget: Widget {
    let kind: String = R.string.widget.kind()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NextSunnyDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(R.string.widget.displayName())
        .description(R.string.widget.description())
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NextSunnyDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NextSunnyDayWidgetEntryView(entry: SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NextSunnyDayWidgetEntryView(entry: SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
