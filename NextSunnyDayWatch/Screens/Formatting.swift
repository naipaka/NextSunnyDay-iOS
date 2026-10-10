import Foundation
import SunnyDay
import SwiftUI
import Weather

// The same wording and formats as the iPhone app (`Formatting.swift`, `SunnyLevelWording.swift`
// and `HeaderTone.swift` there), so that the watch reads like the app and shares its catalog keys.

extension SunnyLevel {
  /// The label over the answer, 「次の晴れ」 or 「次の洗濯日和」.
  var answerTitle: LocalizedStringResource {
    self == .laundry ? "Next Laundry Day" : "Next Sunny Day"
  }

  /// Said when none of the ten days counts.
  var noneInRangeText: LocalizedStringResource {
    self == .laundry ? "No laundry day in the next 10 days" : "No sunny day in the next 10 days"
  }
}

extension Measurement<UnitTemperature> {
  /// Whole degrees in `unit`, without the unit's letter, such as `25°`.
  func degrees(in unit: UnitTemperature) -> String {
    "\(Int(converted(to: unit).value.rounded()))°"
  }
}

extension Date {
  /// Such as 「10/13(火)」 in Japanese.
  var monthDayWeekday: String {
    formatted(.dateTime.month(.defaultDigits).day().weekday(.abbreviated))
  }

  /// Such as 「13日(火)」 in Japanese.
  var dayAndWeekday: String {
    formatted(.dateTime.day().weekday(.abbreviated))
  }

  /// When a forecast was fetched, in the middle of a sentence, such as 「昨日 14:05」.
  var fetchTime: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    formatter.formattingContext = .middleOfSentence
    return formatter.string(from: self)
  }
}

extension String {
  /// WeatherKit's symbol names are used with their filled variant.
  var filledSymbol: String {
    hasSuffix(".fill") ? self : "\(self).fill"
  }
}

/// The color behind the screen, as behind the iPhone's header: orange when a sunny day is in
/// range, gray when none is, a darker gray without data. It gets lighter toward the top, like
/// sunlight; with Increase Contrast it is flat.
enum HeaderTone {
  case sunny
  case gray
  case noData

  var color: Color {
    switch self {
    case .sunny: .orange
    case .gray: .gray
    // watchOS has no numbered system grays: `systemGray` darkened to about `systemGray2` in dark
    // mode, the watch's only appearance.
    case .noData: Color.gray.mix(with: .black, by: 0.3)
    }
  }

  var top: Color {
    switch self {
    case .sunny: color.mix(with: .yellow, by: 0.4).mix(with: .white, by: 0.1)
    case .gray, .noData: color.mix(with: .white, by: 0.18)
    }
  }

  func fill(increasedContrast: Bool) -> AnyShapeStyle {
    if increasedContrast {
      AnyShapeStyle(color)
    } else {
      AnyShapeStyle(LinearGradient(colors: [top, color], startPoint: .top, endPoint: .bottom))
    }
  }
}
