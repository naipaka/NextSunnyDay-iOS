import Foundation
import SunnyDay

/// What the answer is called: the next sunny day, or at the laundry level the next laundry day.
/// The widget words it the same.
extension SunnyLevel {
  /// The label over the answer, 「次の晴れ」 or 「次の洗濯日和」.
  var answerTitle: LocalizedStringResource {
    self == .laundry ? "Next Laundry Day" : "Next Sunny Day"
  }

  /// Said when none of the ten days counts.
  var noneInRangeText: LocalizedStringResource {
    self == .laundry ? "No laundry day in the next 10 days" : "No sunny day in the next 10 days"
  }

  /// The title of the answer day's details when there is no answer: 「次の晴れの日の様子」.
  var answerDayTitle: LocalizedStringResource {
    self == .laundry ? "The Next Laundry Day" : "The Next Sunny Day"
  }

  /// How long the run of days that count lasts: 「晴れは 10月17日(土) まで続きそう」.
  func runText(until day: String) -> LocalizedStringResource {
    self == .laundry ? "Laundry days until \(day)" : "Sunny until \(day)"
  }
}
