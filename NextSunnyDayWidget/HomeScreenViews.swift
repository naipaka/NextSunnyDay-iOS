import Forecast
import SunnyDay
import SwiftUI
import UIKit
import Weather
import WidgetKit

/// 「次の晴れ」, 「あと3日」, the day and the region.
struct SmallWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        WidgetTitle()
        Spacer(minLength: 4)
        WidgetSymbol(state: entry.state)
          .font(.title3)
      }
      Spacer(minLength: 4)
      Headline(state: entry.state, size: 30)
      Detail(state: entry.state)
      Footnote(entry: entry, showsTapToUpdate: true)
    }
  }
}

/// The small layout, with the next five days on the right.
struct MediumWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    HStack(alignment: .bottom, spacing: 8) {
      VStack(alignment: .leading, spacing: 0) {
        WidgetTitle()
        Spacer(minLength: 4)
        Headline(state: entry.state, size: 32)
        Detail(state: entry.state)
        if case .noData = entry.state {
          LastUpdate(entry: entry)
        } else {
          Footnote(entry: entry, showsTapToUpdate: false)
        }
      }
      Spacer(minLength: 0)
      switch entry.state {
      case .noData, .noRegion:
        VStack(spacing: 6) {
          WidgetSymbol(state: entry.state)
            .font(.system(size: 36))
          Footnote(entry: entry, showsTapToUpdate: true)
        }
        .frame(maxHeight: .infinity)
      case .sunny, .noneInRange:
        HStack(spacing: 2) {
          ForEach(entry.days.prefix(5), id: \.date) { day in
            DayColumn(day: day, isToday: day.date == entry.days.first?.date, level: entry.level)
          }
        }
      }
    }
    .overlay(alignment: .topTrailing) {
      AttributionMarkImage(data: entry.attributionMark)
        .frame(height: 9)
    }
  }
}

/// A header like the small widget's, then seven days.
struct LargeWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 0) {
          WidgetTitle()
          Headline(state: entry.state, size: 30)
          if case .sunny(let next) = entry.state, let placeName = entry.placeName {
            Text(
              verbatim:
                "\(next.day.date.monthDayWeekday) \(next.day.condition.localizedName) · \(placeName)"
            )
            .font(.caption2.weight(.bold))
            .lineLimit(1)
          } else {
            Detail(state: entry.state)
          }
        }
        Spacer(minLength: 4)
        WidgetSymbol(state: entry.state)
          .font(.system(size: 40))
      }
      switch entry.state {
      case .noData, .noRegion:
        Spacer(minLength: 0)
        Footnote(entry: entry, showsTapToUpdate: true)
          .frame(maxWidth: .infinity)
        Spacer(minLength: 0)
      case .sunny, .noneInRange:
        VStack(spacing: 2) {
          ForEach(entry.days.prefix(7), id: \.date) { day in
            DayRow(day: day, isToday: day.date == entry.days.first?.date, level: entry.level)
          }
        }
        Spacer(minLength: 0)
      }
      AttributionMarkImage(data: entry.attributionMark)
        .frame(height: 10)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }
}

// MARK: - Parts

/// 「次の晴れ」.
struct WidgetTitle: View {
  var body: some View {
    Text("Next Sunny Day")
      .font(.caption2.weight(.bold))
  }
}

/// The weather symbol of the next sunny day, or why there is none.
struct WidgetSymbol: View {
  let state: SunnyEntry.State

  var body: some View {
    Image(systemName: state.symbolName)
      .widgetAccentable()
  }
}

/// 「あと3日」, 「まだ先かも」 or 「あと？日」.
private struct Headline: View {
  let state: SunnyEntry.State
  let size: CGFloat

  var body: some View {
    state.headline
      .font(.system(size: size, weight: .bold))
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .widgetAccentable()
  }
}

/// The day and its condition, or why there is none.
private struct Detail: View {
  let state: SunnyEntry.State

  var body: some View {
    state.detail
      .font(.caption2.weight(.bold))
      .lineLimit(1)
      .minimumScaleFactor(0.7)
  }
}

/// The region's name, or 「タップして更新」 when there is no data. Tapping opens the app, which
/// fetches when it becomes active.
private struct Footnote: View {
  let entry: SunnyEntry
  let showsTapToUpdate: Bool

  var body: some View {
    Group {
      switch entry.state {
      case .sunny, .noneInRange:
        if let placeName = entry.placeName {
          Text(verbatim: placeName)
        } else {
          Text("Current Location")
        }
      case .noData:
        if showsTapToUpdate { Text("Tap to update") }
      case .noRegion:
        EmptyView()
      }
    }
    .font(.caption2)
    .lineLimit(1)
    .opacity(0.85)
  }
}

/// When the forecast that has run out was fetched, for the medium widget without data.
private struct LastUpdate: View {
  let entry: SunnyEntry

  var body: some View {
    if let fetchedAt = entry.cached?.fetchedAt {
      Text("Last updated \(fetchedAt.relativeDayAndTime)")
        .font(.caption2)
        .lineLimit(1)
        .opacity(0.85)
    }
  }
}

/// A day in the medium widget: weekday, symbol, high. Sunny days get a light capsule.
private struct DayColumn: View {
  let day: DayForecast
  let isToday: Bool
  let level: SunnyLevel

  var body: some View {
    VStack(spacing: 4) {
      Group {
        if isToday { Text("Today") } else { Text(verbatim: day.date.weekday) }
      }
      .font(.caption2.weight(.bold))
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      Image(systemName: day.symbolName.filledSymbol)
        .font(.body)
        .frame(height: 22)
      Text(verbatim: day.highTemperature.degrees)
        .font(.caption.weight(.semibold))
    }
    .frame(width: 34)
    .padding(.vertical, 6)
    .background {
      if level.counts(day) {
        Capsule().fill(.white.opacity(0.25))
      }
    }
  }
}

/// A day in the large widget: date, symbol, condition, high and low. Sunny rows are bold on a
/// light capsule.
private struct DayRow: View {
  let day: DayForecast
  let isToday: Bool
  let level: SunnyLevel

  var body: some View {
    let isSunny = level.counts(day)
    HStack(spacing: 8) {
      Group {
        if isToday { Text("Today") } else { Text(verbatim: day.date.dayAndWeekday) }
      }
      .frame(width: 64, alignment: .leading)
      Image(systemName: day.symbolName.filledSymbol)
        .frame(width: 24)
      Text(verbatim: day.condition.localizedName)
        .font(.caption)
        .lineLimit(1)
      Spacer(minLength: 4)
      Text(verbatim: "\(day.highTemperature.degrees) \(day.lowTemperature.degrees)")
        .monospacedDigit()
    }
    .font(.footnote.weight(isSunny ? .bold : .regular))
    .padding(.horizontal, 8)
    .padding(.vertical, 5)
    .background {
      if isSunny {
        Capsule().fill(.white.opacity(0.25))
      }
    }
  }
}

/// The Apple Weather mark, which WeatherKit requires wherever its data is shown. The legal link
/// is in the app.
struct AttributionMarkImage: View {
  let data: Data?

  var body: some View {
    if let data, let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
        .accessibilityLabel(Text(verbatim: "Apple Weather"))
    }
  }
}
