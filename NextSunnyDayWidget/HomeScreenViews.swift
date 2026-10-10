import Forecast
import SunnyDay
import SwiftUI
import UIKit
import Weather
import WidgetKit

/// The answer on top: the region, 「あと3日」 and the day. Below a line, today's weather.
struct SmallWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      AnswerLabel(entry: entry)
      Spacer(minLength: 4)
      Headline(state: entry.state, size: 32)
      Detail(state: entry.state)
      if case .noData = entry.state {
        Text("Tap to update")
          .font(.caption2)
          .opacity(0.9)
      }
      Line()
        .padding(.top, 8)
        .padding(.bottom, 7)
      TodayRow(today: entry.today)
    }
  }
}

/// The answer and, split by a line, today's weather in a column.
struct MediumWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top) {
          AnswerLabel(entry: entry)
          Spacer(minLength: 4)
          AttributionMarkImage(data: entry.attributionMark)
            .frame(height: 9)
        }
        Spacer(minLength: 4)
        Headline(state: entry.state, size: 44)
        Detail(state: entry.state)
        if case .noData = entry.state {
          LastUpdate(entry: entry)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      Line(vertical: true)
      TodayColumn(today: entry.today)
        .frame(width: 84)
    }
  }
}

/// The medium layout on top, then six days from tomorrow.
struct LargeWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 0) {
          AnswerLabel(entry: entry)
          Spacer(minLength: 4)
          Headline(state: entry.state, size: 44)
          Detail(state: entry.state)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Line(vertical: true)
        TodayColumn(today: entry.today)
          .frame(width: 84)
      }
      .frame(height: 116)
      Line()
      switch entry.state {
      case .noData:
        Spacer(minLength: 0)
        VStack(spacing: 4) {
          Text("Tap to update")
            .font(.subheadline.weight(.semibold))
          LastUpdate(entry: entry)
        }
        .frame(maxWidth: .infinity)
        Spacer(minLength: 0)
      case .noRegion:
        // Where the days go once a region is chosen.
        // Where the days go once a region is chosen.
        VStack(spacing: 3) {
          ForEach(0..<6, id: \.self) { _ in
            PlaceholderDayRow()
          }
        }
      case .sunny, .noneInRange:
        VStack(spacing: 3) {
          ForEach(entry.laterDays.prefix(6), id: \.date) { day in
            DayRow(day: day, level: entry.level, temperatureUnit: entry.temperatureUnit)
          }
        }
      }
      AttributionMarkImage(data: entry.attributionMark)
        .frame(height: 10)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }
}

// MARK: - Parts

/// 「港区 · 次の晴れ」, or 「次の晴れ」 without a region; 「次の洗濯日和」 at the laundry level.
private struct AnswerLabel: View {
  let entry: SunnyEntry

  var body: some View {
    Group {
      if entry.region == nil {
        Text(entry.level.answerTitle)
      } else {
        let place = entry.placeName ?? String(localized: "Current Location")
        Text(verbatim: "\(place) · \(String(localized: entry.level.answerTitle))")
      }
    }
    .font(.footnote.weight(.semibold))
    .lineLimit(1)
    .minimumScaleFactor(0.8)
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

/// The day's symbol, date and condition, or why there is no day.
private struct Detail: View {
  let state: SunnyEntry.State

  var body: some View {
    HStack(spacing: 4) {
      if case .sunny = state {
        Image(systemName: state.symbolName)
          .widgetAccentable()
      }
      state.detail
    }
    .font(.caption.weight(.semibold))
    .lineLimit(1)
    .minimumScaleFactor(0.7)
  }
}

/// The small widget's last row: 「今日」 and today's symbol and condition.
private struct TodayRow: View {
  let today: DayForecast?

  var body: some View {
    HStack(spacing: 6) {
      Text("Today")
      Spacer(minLength: 4)
      if let today {
        HStack(spacing: 4) {
          Image(systemName: today.symbolName.filledSymbol)
          Text(verbatim: today.condition.localizedName)
            .lineLimit(1)
        }
      } else {
        Text(verbatim: "—")
      }
    }
    .font(.caption.weight(.semibold))
    .accessibilityElement(children: .combine)
  }
}

/// 「今日」, today's symbol and its condition, centered in a column.
private struct TodayColumn: View {
  let today: DayForecast?

  var body: some View {
    VStack(spacing: 4) {
      Text("Today")
        .font(.caption.weight(.bold))
      Spacer(minLength: 0)
      if let today {
        Image(systemName: today.symbolName.filledSymbol)
          .font(.system(size: 34))
        Spacer(minLength: 0)
        Text(verbatim: today.condition.localizedName)
          .font(.caption.weight(.semibold))
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .minimumScaleFactor(0.8)
      } else {
        Text(verbatim: "—")
          .font(.title3)
        Spacer(minLength: 0)
      }
    }
    .frame(maxHeight: .infinity)
    .accessibilityElement(children: .combine)
  }
}

/// A 1 pt white line between the answer and today.
private struct Line: View {
  var vertical = false

  var body: some View {
    Rectangle()
      .fill(.white.opacity(0.4))
      .frame(width: vertical ? 1 : nil, height: vertical ? nil : 1)
  }
}

/// When the forecast that has run out was fetched, for the medium and large widgets without data.
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

/// A day in the large widget: date, symbol, condition, high and low. The six rows share the
/// height below the answer. Sunny rows are bold on a light rounded rectangle.
private struct DayRow: View {
  let day: DayForecast
  let level: SunnyLevel
  let temperatureUnit: UnitTemperature

  var body: some View {
    let isSunny = level.counts(day)
    HStack(spacing: 0) {
      Text(verbatim: day.date.dayAndWeekday)
        .frame(width: 76, alignment: .leading)
      Image(systemName: day.symbolName.filledSymbol)
        .frame(width: 28, alignment: .leading)
      Text(verbatim: day.condition.localizedName)
        .lineLimit(1)
      Spacer(minLength: 4)
      HStack(spacing: 4) {
        Text(verbatim: day.highTemperature.degrees(in: temperatureUnit))
        Text(verbatim: day.lowTemperature.degrees(in: temperatureUnit))
          .opacity(0.75)
      }
      .monospacedDigit()
    }
    .font(.subheadline.weight(isSunny ? .bold : .regular))
    .lineLimit(1)
    .minimumScaleFactor(0.8)
    .padding(.horizontal, 10)
    .frame(maxHeight: .infinity)
    .background {
      if isSunny {
        RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white.opacity(0.25))
      }
    }
  }
}

/// A day row without data, drawn redacted.
private struct PlaceholderDayRow: View {
  var body: some View {
    HStack(spacing: 0) {
      Text(verbatim: "00 (00)")
        .frame(width: 76, alignment: .leading)
      Image(systemName: "sun.max.fill")
        .frame(width: 28, alignment: .leading)
      Text(verbatim: "000000")
      Spacer(minLength: 4)
      Text(verbatim: "00° 00°")
    }
    .font(.subheadline)
    .padding(.horizontal, 10)
    .frame(maxHeight: .infinity)
    .redacted(reason: .placeholder)
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
