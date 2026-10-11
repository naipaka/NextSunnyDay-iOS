import SunnyDay
import SwiftUI
import Weather

/// Sunrise, sunset, UV index and wind of a day, as the day detail screen and the wider layouts
/// show them.
struct DayFact: Identifiable {
  let symbol: String
  let title: LocalizedStringKey
  let value: Text

  var id: String { symbol }

  /// The four facts of `day`, or of no day: 「—」 for each value, keeping their place.
  static func facts(of day: DayForecast?) -> [DayFact] {
    let none = Text(verbatim: "—")
    return [
      DayFact(
        symbol: "sunrise.fill", title: "Sunrise",
        value: day?.sunrise.map { Text(verbatim: $0.time) } ?? none),
      DayFact(
        symbol: "sunset.fill", title: "Sunset",
        value: day?.sunset.map { Text(verbatim: $0.time) } ?? none),
      DayFact(
        symbol: "sun.max.trianglebadge.exclamationmark", title: "UV Index",
        value: day.map { Text(verbatim: "\($0.uvIndex)") } ?? none),
      DayFact(symbol: "wind", title: "Wind", value: day.map(wind) ?? none),
    ]
  }

  private static func wind(_ day: DayForecast) -> Text {
    Text(
      "\(day.windDirection.compassDirection) \(day.windSpeed.formatted(.measurement(width: .abbreviated, usage: .wind, numberFormatStyle: .number.precision(.fractionLength(0)))))"
    )
  }
}

/// The title over the answer day's facts: 「10月14日(水) の様子」, or without an answer
/// 「次の晴れの日の様子」.
struct AnswerDayTitle: View {
  let day: DayForecast?
  let level: SunnyLevel

  var body: some View {
    if let day {
      Text("On \(day.date.dayWithWeekday)")
    } else {
      Text(level.answerDayTitle)
    }
  }
}

/// The answer day's facts in white on the header color, in a grid of `columns`.
struct AnswerDayFacts: View {
  let day: DayForecast?
  let level: SunnyLevel
  var columns = 2

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      AnswerDayTitle(day: day, level: level)
        .font(.subheadline.weight(.semibold))
        .opacity(0.95)
      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: columns),
        alignment: .leading, spacing: 14
      ) {
        ForEach(DayFact.facts(of: day)) { fact in
          VStack(alignment: .leading, spacing: 2) {
            Text(fact.title)
              .font(.footnote)
              .opacity(0.9)
            fact.value
              .font(.title3.weight(.semibold))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          .accessibilityElement(children: .combine)
        }
      }
    }
  }
}

/// The facts as four tiles, for the day detail screen's panel layout.
struct DayFactTiles: View {
  let day: DayForecast

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

  var body: some View {
    LazyVGrid(columns: columns, spacing: 10) {
      ForEach(DayFact.facts(of: day)) { fact in
        VStack(alignment: .leading, spacing: 8) {
          Label {
            Text(fact.title)
          } icon: {
            Image(systemName: fact.symbol).symbolRenderingMode(.multicolor)
          }
          .font(.footnote)
          .foregroundStyle(.secondary)
          fact.value
            .font(.title3.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
          Color(.secondarySystemGroupedBackground),
          in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .accessibilityElement(children: .combine)
      }
    }
  }
}
