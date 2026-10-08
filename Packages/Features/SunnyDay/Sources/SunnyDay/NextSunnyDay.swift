public import Foundation
public import Weather

/// The first day that counts as sunny, and how many days away it is.
public struct NextSunnyDay: Equatable, Sendable {
  public var day: DayForecast
  /// 0 for today, 1 for tomorrow.
  public var daysAway: Int

  public init(day: DayForecast, daysAway: Int) {
    self.day = day
    self.daysAway = daysAway
  }
}

extension SunnyLevel {
  /// The first day from today on that counts as sunny at this level, or `nil` if none does.
  /// Days before today, left in an old forecast, are skipped.
  public func nextSunnyDay(
    in days: [DayForecast], now: Date = .now, calendar: Calendar = .current
  ) -> NextSunnyDay? {
    let today = calendar.startOfDay(for: now)
    return
      days
      .lazy
      .map {
        (
          day: $0,
          daysAway: calendar.dateComponents(
            [.day], from: today, to: calendar.startOfDay(for: $0.date)
          ).day ?? 0
        )
      }
      .filter { $0.daysAway >= 0 && counts($0.day) }
      .min { $0.daysAway < $1.daysAway }
      .map { NextSunnyDay(day: $0.day, daysAway: $0.daysAway) }
  }
}
