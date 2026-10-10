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

  /// The next sunny day's date without its condition, or a shorter `detail`, for the Lock Screen.
  var shortDate: Text {
    switch self {
    case .sunny(let next): Text(verbatim: next.day.date.monthDayWeekday)
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

  /// System orange when a sunny day is in range, `systemGray` when none is and `systemGray2`
  /// without data or a region, lighter toward the top like Home's header (the app's
  /// `HeaderTone`). With Increase Contrast, the flat color.
  func background(increasedContrast: Bool) -> AnyShapeStyle {
    let color: Color =
      switch self {
      case .sunny: .orange
      case .noneInRange: Color(.systemGray)
      case .noData, .noRegion: Color(.systemGray2)
      }
    guard !increasedContrast else { return AnyShapeStyle(color) }
    let top: Color =
      if case .sunny = self {
        color.mix(with: .yellow, by: 0.4).mix(with: .white, by: 0.1)
      } else {
        color.mix(with: .white, by: 0.18)
      }
    return AnyShapeStyle(LinearGradient(colors: [top, color], startPoint: .top, endPoint: .bottom))
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

extension SunnyLevel {
  /// The label over the answer, 「次の晴れ」 or 「次の洗濯日和」, as the app words it
  /// (`SunnyLevelWording.swift` in the app).
  var answerTitle: LocalizedStringResource {
    self == .laundry ? "Next Laundry Day" : "Next Sunny Day"
  }
}
