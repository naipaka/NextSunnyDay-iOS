public import Foundation
public import Weather

/// The first day after today that counts as sunny, how many days away it is, and the last day
/// of the run of days that count from it.
public struct NextSunnyDay: Equatable, Sendable {
  public var day: DayForecast
  /// 1 for tomorrow.
  public var daysAway: Int
  /// The last of the days in a row that count, starting with `day`; `day` itself when the next
  /// one doesn't count or isn't in the forecast.
  public var lastDay: DayForecast

  public init(day: DayForecast, daysAway: Int, lastDay: DayForecast? = nil) {
    self.day = day
    self.daysAway = daysAway
    self.lastDay = lastDay ?? day
  }

  /// Whether the run goes on after `day`.
  public var lastsMoreThanADay: Bool { lastDay.date != day.date }
}

extension SunnyLevel {
  /// The first day from tomorrow on that counts as sunny at this level, or `nil` if none does,
  /// with the last day of the run that starts there.
  /// Today is never the answer: its weather can be seen by looking outside. Days before today,
  /// left in an old forecast, are skipped too.
  public func nextSunnyDay(
    in days: [DayForecast], now: Date = .now, calendar: Calendar = .current
  ) -> NextSunnyDay? {
    let today = calendar.startOfDay(for: now)
    let dated = days.map {
      (
        day: $0,
        daysAway: calendar.dateComponents(
          [.day], from: today, to: calendar.startOfDay(for: $0.date)
        ).day ?? 0
      )
    }
    guard
      let first =
        dated
        .filter({ $0.daysAway >= 1 && counts($0.day) })
        .min(by: { $0.daysAway < $1.daysAway })
    else { return nil }
    var last = first
    while let next = dated.first(where: { $0.daysAway == last.daysAway + 1 }), counts(next.day) {
      last = next
    }
    return NextSunnyDay(day: first.day, daysAway: first.daysAway, lastDay: last.day)
  }
}
