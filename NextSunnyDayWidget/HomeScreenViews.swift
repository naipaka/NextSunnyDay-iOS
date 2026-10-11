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

/// iPad's extra large widget: the medium layout on top, then seven days from tomorrow as
/// columns, the next sunny day outlined so it lines up with the answer.
struct ExtraLargeWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      ExtraLargeTop(entry: entry, headlineSize: 48)
      Line()
      HStack(spacing: 4) {
        switch entry.state {
        case .sunny, .noneInRange:
          ForEach(entry.laterDays.prefix(7), id: \.date) { day in
            DayColumn(day: day, entry: entry)
          }
        case .noData, .noRegion:
          ForEach(0..<7, id: \.self) { _ in
            DayColumn(day: nil, entry: entry)
          }
        }
      }
      .frame(height: 112)
    }
  }
}

/// iPhone's extra large widget, a full Home Screen page: the top area, the next sunny day's
/// hours, and seven days from tomorrow with range bars. The chart shows the answer day, so it
/// only changes with the answer; without one it keeps its place, empty.
struct ExtraLargePortraitWidgetView: View {
  let entry: SunnyEntry

  private var next: NextSunnyDay? {
    if case .sunny(let next) = entry.state { next } else { nil }
  }

  /// Every second hour of the next sunny day.
  private var hours: [HourForecast] {
    guard let next, let hourly = entry.cached?.forecast.hourly else { return [] }
    return
      hourly
      .filter { Calendar.current.isDate($0.date, inSameDayAs: next.day.date) }
      .filter { Calendar.current.component(.hour, from: $0.date).isMultiple(of: 2) }
  }

  private var days: [DayForecast] { Array(entry.laterDays.prefix(7)) }

  /// The scale of the range bars: the shown days' lowest low to highest high, in Celsius.
  private var range: ClosedRange<Double> {
    let low = days.map { $0.lowTemperature.converted(to: .celsius).value }.min() ?? 0
    let high = days.map { $0.highTemperature.converted(to: .celsius).value }.max() ?? 1
    return low...max(high, low + 1)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ExtraLargeTop(entry: entry, headlineSize: 40)
        .frame(height: 112)
      Line()
      Group {
        if let next {
          Text("Hourly on \(next.day.date.monthDayWeekday)")
        } else {
          Text(entry.level.answerDayHoursTitle)
        }
      }
      .font(.caption.weight(.semibold))
      .opacity(0.9)
      HourChart(hours: hours, temperatureUnit: entry.temperatureUnit)
        .frame(height: 104)
      Line()
      VStack(spacing: 3) {
        switch entry.state {
        case .sunny, .noneInRange:
          ForEach(days, id: \.date) { day in
            RangeRow(day: day, entry: entry, range: range)
          }
        case .noData, .noRegion:
          ForEach(0..<7, id: \.self) { _ in
            PlaceholderDayRow()
          }
        }
      }
    }
  }
}

/// The extra large widgets' top: the answer with its day and temperatures, and today's column.
private struct ExtraLargeTop: View {
  let entry: SunnyEntry
  let headlineSize: CGFloat

  var body: some View {
    HStack(spacing: 18) {
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top) {
          AnswerLabel(entry: entry)
          Spacer(minLength: 4)
          AttributionMarkImage(data: entry.attributionMark)
            .frame(height: 9)
        }
        Spacer(minLength: 4)
        Headline(state: entry.state, size: headlineSize)
        Detail(state: entry.state)
        switch entry.state {
        case .sunny(let next):
          Text(
            "High \(next.day.highTemperature.degrees(in: entry.temperatureUnit)) Low \(next.day.lowTemperature.degrees(in: entry.temperatureUnit))"
          )
          .font(.caption)
          .opacity(0.9)
        case .noData:
          Text("Tap to update")
            .font(.caption)
            .opacity(0.9)
        default:
          EmptyView()
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      Line(vertical: true)
      TodayColumn(today: entry.today)
        .frame(width: 88)
    }
  }
}

/// A day of the iPad extra large widget: date, symbol, condition, high and low. Days that count
/// are on a light band; the next sunny day is also outlined and marked.
private struct DayColumn: View {
  let day: DayForecast?
  let entry: SunnyEntry

  var body: some View {
    let isSunny = day.map(entry.level.counts) ?? false
    let isNext = day.map(isNextSunnyDay) ?? false
    VStack(spacing: 3) {
      Text(entry.level.answerTitle)
        .font(.system(size: 10, weight: .bold))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .opacity(isNext ? 1 : 0)
      if let day {
        Text(verbatim: day.date.dayAndWeekday)
          .font(.caption.weight(isSunny ? .bold : .medium))
        Image(systemName: day.symbolName.filledSymbol)
          .font(.title3)
          .frame(height: 24)
        Text(verbatim: day.condition.localizedName)
          .font(.caption2.weight(isSunny ? .bold : .regular))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        HStack(spacing: 3) {
          Text(verbatim: day.highTemperature.degrees(in: entry.temperatureUnit))
          Text(verbatim: day.lowTemperature.degrees(in: entry.temperatureUnit)).opacity(0.8)
        }
        .font(.caption.weight(.semibold).monospacedDigit())
      } else {
        Group {
          Text(verbatim: "00(0)").font(.caption)
          Image(systemName: "sun.max.fill").font(.title3).frame(height: 24)
          Text(verbatim: "000").font(.caption2)
          Text(verbatim: "00° 00°").font(.caption)
        }
        .redacted(reason: .placeholder)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
      if isSunny {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(.white.opacity(isNext ? 0.32 : 0.2))
      }
    }
    .overlay {
      if isNext {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .strokeBorder(.white.opacity(0.9), lineWidth: 2)
      }
    }
    .accessibilityElement(children: .combine)
  }

  private func isNextSunnyDay(_ day: DayForecast) -> Bool {
    if case .sunny(let next) = entry.state { next.day.date == day.date } else { false }
  }
}

/// A day of the iPhone extra large widget with a range bar; the next sunny day outlined.
private struct RangeRow: View {
  let day: DayForecast
  let entry: SunnyEntry
  let range: ClosedRange<Double>

  var body: some View {
    let isSunny = entry.level.counts(day)
    let isNext: Bool = {
      if case .sunny(let next) = entry.state { next.day.date == day.date } else { false }
    }()
    HStack(spacing: 8) {
      Text(verbatim: day.date.dayAndWeekday)
        .frame(width: 58, alignment: .leading)
      Image(systemName: day.symbolName.filledSymbol)
        .frame(width: 22)
      Text(verbatim: day.condition.localizedName)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
      Text(verbatim: day.lowTemperature.degrees(in: entry.temperatureUnit))
        .opacity(0.85)
        .frame(width: 30, alignment: .trailing)
      WidgetRangeBar(
        low: day.lowTemperature.converted(to: .celsius).value,
        high: day.highTemperature.converted(to: .celsius).value, range: range
      )
      .frame(width: 64)
      Text(verbatim: day.highTemperature.degrees(in: entry.temperatureUnit))
        .frame(width: 30, alignment: .leading)
    }
    .font(.caption.weight(isSunny ? .bold : .medium).monospacedDigit())
    .lineLimit(1)
    .minimumScaleFactor(0.8)
    .padding(.horizontal, 10)
    .frame(maxHeight: .infinity)
    .background {
      if isSunny {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(.white.opacity(isNext ? 0.32 : 0.18))
      }
    }
    .overlay {
      if isNext {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .strokeBorder(.white.opacity(0.9), lineWidth: 1.5)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

/// A day's low to high in white on a light track.
private struct WidgetRangeBar: View {
  let low: Double
  let high: Double
  let range: ClosedRange<Double>

  var body: some View {
    GeometryReader { proxy in
      let span = max(range.upperBound - range.lowerBound, 1)
      let start = (low - range.lowerBound) / span * proxy.size.width
      let end = (high - range.lowerBound) / span * proxy.size.width
      Capsule()
        .fill(.white.opacity(0.3))
        .overlay(alignment: .leading) {
          Capsule()
            .fill(.white)
            .frame(width: max(end - start, 5))
            .offset(x: start)
        }
    }
    .frame(height: 5)
    .accessibilityHidden(true)
  }
}

/// Hours as columns of time, symbol and temperature over a white temperature line; empty, with
/// placeholders, without hours.
private struct HourChart: View {
  let hours: [HourForecast]
  let temperatureUnit: UnitTemperature

  var body: some View {
    if hours.isEmpty {
      VStack(spacing: 8) {
        HStack(spacing: 0) {
          ForEach(0..<12, id: \.self) { _ in
            Capsule().fill(.white.opacity(0.28)).frame(width: 14, height: 8)
              .frame(maxWidth: .infinity)
          }
        }
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(.white.opacity(0.12))
          .overlay {
            Rectangle()
              .fill(.white.opacity(0.45))
              .frame(height: 2)
              .padding(.horizontal, 10)
          }
      }
      .accessibilityHidden(true)
    } else {
      VStack(spacing: 4) {
        HStack(spacing: 0) {
          ForEach(hours, id: \.date) { hour in
            VStack(spacing: 3) {
              Text(verbatim: hour.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted))))
                .font(.system(size: 10))
                .opacity(0.9)
              Image(systemName: hour.symbolName.filledSymbol)
                .font(.footnote)
                .frame(height: 16)
              Text(verbatim: hour.temperature.degrees(in: temperatureUnit))
                .font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
          }
        }
        HourCurve(values: hours.map { $0.temperature.converted(to: .celsius).value })
          .stroke(.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
          .background {
            HourCurve(
              values: hours.map { $0.temperature.converted(to: .celsius).value }, closed: true
            )
            .fill(.white.opacity(0.18))
          }
      }
      .accessibilityElement(children: .combine)
    }
  }
}

/// The temperature line through the middle of each column, smoothed; closed to the bottom for
/// the area under it.
private struct HourCurve: Shape {
  let values: [Double]
  var closed = false

  func path(in rect: CGRect) -> Path {
    guard let low = values.min(), let high = values.max() else { return Path() }
    let span = max(high - low, 1)
    let step = rect.width / CGFloat(values.count)
    let points = values.enumerated().map { index, value in
      CGPoint(
        x: rect.minX + step * (CGFloat(index) + 0.5),
        y: rect.maxY - 4 - (value - low) / span * (rect.height - 8))
    }
    var path = Path()
    guard let first = points.first, let last = points.last else { return path }
    path.move(to: first)
    for index in points.indices.dropLast() {
      let p0 = points[max(index - 1, 0)]
      let p1 = points[index]
      let p2 = points[index + 1]
      let p3 = points[min(index + 2, points.count - 1)]
      path.addCurve(
        to: p2,
        control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
        control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6))
    }
    if closed {
      path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
      path.addLine(to: CGPoint(x: first.x, y: rect.maxY))
      path.closeSubpath()
    }
    return path
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
