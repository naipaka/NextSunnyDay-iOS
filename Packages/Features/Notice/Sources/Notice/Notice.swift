public import Foundation
public import Weather

/// A notification that a sunny day comes tomorrow.
public struct Notice: Equatable, Sendable {
  /// When it goes out: the day before `day`, at the chosen time.
  public var date: Date
  /// The sunny day.
  public var day: DayForecast

  public init(date: Date, day: DayForecast) {
    self.date = date
    self.day = day
  }
}

extension NoticeSetting {
  /// How old a forecast may be when a notification based on it goes out. A scheduled
  /// notification can't be taken back until the next fetch, so a forecast several days old
  /// notifies nothing. Two days, so that a forecast fetched in the morning still covers the
  /// evening of the next day.
  public static let maximumForecastAge: TimeInterval = 2 * 24 * 60 * 60

  /// The notifications for `days`: one the day before each day that is sunny after a day that
  /// isn't, so a sunny spell is announced once. Only those still ahead of `now`, and only those
  /// that go out within `maximumForecastAge` of `fetchedAt`. None while the setting is off.
  public func notices(
    in days: [DayForecast], fetchedAt: Date, now: Date = .now, calendar: Calendar = .current,
    isSunny: (DayForecast) -> Bool
  ) -> [Notice] {
    guard isOn else { return [] }
    let latest = fetchedAt.addingTimeInterval(Self.maximumForecastAge)
    let days = days.sorted { $0.date < $1.date }
    return zip(days, days.dropFirst()).compactMap { dayBefore, day in
      guard
        calendar.dateComponents(
          [.day], from: calendar.startOfDay(for: dayBefore.date),
          to: calendar.startOfDay(for: day.date)
        ).day == 1,
        !isSunny(dayBefore), isSunny(day),
        let date = calendar.date(
          bySettingHour: time.hour, minute: time.minute, second: 0, of: dayBefore.date),
        date > now, date <= latest
      else { return nil }
      return Notice(date: date, day: day)
    }
  }
}
