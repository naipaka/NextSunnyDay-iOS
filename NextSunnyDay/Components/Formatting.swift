import Foundation
import Weather

extension Measurement<UnitTemperature> {
  /// Whole degrees in the user's unit for weather, without the unit, such as `25°`.
  var degrees: String {
    let unit = UnitTemperature(forLocale: .current, usage: .weather)
    return "\(Int(converted(to: unit).value.rounded()))°"
  }
}

extension Double {
  /// A chance from 0 to 1 as a whole percentage, such as `30%`.
  var percent: String {
    formatted(.percent.precision(.fractionLength(0)))
  }

  /// Whether a precipitation chance is worth showing: 20 % or more.
  var isShownAsPrecipitation: Bool { self >= 0.2 }
}

extension Date {
  /// The day with its weekday, such as 「10月10日（土）」 in Japanese.
  var dayWithWeekday: String {
    formatted(.dateTime.month(.abbreviated).day().weekday(.abbreviated))
  }

  /// The month and day in digits, such as `10/9`.
  var monthDay: String {
    formatted(.dateTime.month(.defaultDigits).day())
  }

  /// The hour, such as 「15時」 in Japanese.
  var hour: String {
    formatted(.dateTime.hour())
  }

  /// The time, such as `14:05`.
  var time: String {
    formatted(date: .omitted, time: .shortened)
  }

  /// When a forecast was fetched, in the middle of a sentence, with the relative day the system
  /// uses for the language, such as 「昨日 14:05」 or "yesterday at 2:05 PM".
  var fetchTime: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    formatter.formattingContext = .middleOfSentence
    return formatter.string(from: self)
  }
}

extension Measurement<UnitAngle> {
  /// The compass direction the wind blows from.
  var compassDirection: LocalizedStringResource {
    let directions: [LocalizedStringResource] = [
      "North", "Northeast", "East", "Southeast", "South", "Southwest", "West", "Northwest",
    ]
    let degrees = converted(to: .degrees).value
    let index = Int((degrees / 45).rounded()) % directions.count
    return directions[(index + directions.count) % directions.count]
  }
}
