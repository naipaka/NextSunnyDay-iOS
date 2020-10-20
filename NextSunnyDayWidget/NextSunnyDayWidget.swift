//
//  NextSunnyDayWidget.swift
//  NextSunnyDayWidget
//
//  Created by rMac on 2020/10/19.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), entity: DailyWeatherForecastEntity())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, entity: DailyWeatherForecastEntity())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
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
