import Foundation
import SunnyDay
import SwiftUI
import Weather

extension SunnyEntry.State {
  /// 「あと3日」, 「まだ先かも」 or 「あと？日」.
  var headline: Text {
    switch self {
    case .sunny(let next): Text(daysAway: next.daysAway)
    case .noneInRange: Text("Maybe not for a while")
    case .noData, .noRegion: Text("In ? days")
    }
  }

  /// The next sunny day with its condition, or why there is none.
  var detail: Text {
    switch self {
    case .sunny(let next):
      Text(verbatim: "\(next.day.date.monthDayWeekday) \(next.day.condition.localizedName)")
    case .noneInRange: Text("None in the next 10 days")
    case .noData: Text("Couldn't get the weather")
    case .noRegion: Text("Choose a region in the app")
    }
  }

  /// A shorter `detail` for the Lock Screen.
  var shortDetail: Text {
    switch self {
    case .noData: Text("Couldn't get it")
    default: detail
    }
  }

  var symbolName: String {
    switch self {
    case .sunny(let next): next.day.symbolName.filledSymbol
    case .noneInRange: "cloud.fill"
    case .noData: "icloud.slash.fill"
    case .noRegion: "location.slash.fill"
    }
  }

  /// System orange when a sunny day is in range, gray otherwise.
  var background: Color {
    if case .sunny = self { .orange } else { Color(.systemGray) }
  }
}

extension Text {
  /// 「あした」 or 「あと3日」.
  init(daysAway: Int) {
    if daysAway == 1 {
      self.init("Tomorrow")
    } else {
      self.init("In \(daysAway) days")
    }
  }
}

extension String {
  /// WeatherKit's symbol names are used with their filled variant.
  var filledSymbol: String {
    hasSuffix(".fill") ? self : "\(self).fill"
  }
}

extension Measurement<UnitTemperature> {
  /// Whole degrees in `unit`, without the unit's letter, such as `25°`.
  func degrees(in unit: UnitTemperature) -> String {
    "\(Int(converted(to: unit).value.rounded()))°"
  }
}

extension Date {
  /// Such as 「10/10(土)」 in Japanese.
  var monthDayWeekday: String {
    formatted(.dateTime.month(.defaultDigits).day().weekday(.abbreviated))
  }

  /// Such as 「10日(土)」 in Japanese.
  var dayAndWeekday: String {
    formatted(.dateTime.day().weekday(.abbreviated))
  }

  /// Such as 「土」 in Japanese.
  var weekday: String {
    formatted(.dateTime.weekday(.abbreviated))
  }

  /// Such as 「昨日 14:05」 in Japanese.
  var relativeDayAndTime: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    return formatter.string(from: self)
  }
}
