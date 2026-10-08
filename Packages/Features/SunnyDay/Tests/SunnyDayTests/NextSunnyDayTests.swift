import Foundation
import SunnyDay
import Testing
import Weather
import WeatherTesting

struct NextSunnyDayTests {
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    return calendar
  }()

  /// 8 October 2026, 10:00 in Tokyo: the day the recordings start.
  var now: Date { calendar.date(from: DateComponents(year: 2026, month: 10, day: 8, hour: 10))! }

  @Test func findsTheFirstSunnyDayOfTheRecording() throws {
    let days = WeatherRecording.tokyo.forecast(startingOn: now, calendar: calendar).daily

    // Tokyo starts mostly clear, then clear.
    let next = try #require(SunnyLevel.clear.nextSunnyDay(in: days, now: now, calendar: calendar))
    #expect(next.daysAway == 1)
    #expect(next.day.condition == .clear)
    #expect(
      SunnyLevel.mostlyClear.nextSunnyDay(in: days, now: now, calendar: calendar)?.daysAway == 0)
  }

  @Test func noDayIsSunnyInTheRainyRecording() {
    let days = WeatherRecording.singapore.forecast(startingOn: now, calendar: calendar).daily

    #expect(SunnyLevel.noRain.nextSunnyDay(in: days, now: now, calendar: calendar) == nil)
  }

  @Test func daysBeforeTodayAreSkipped() throws {
    // Fetched two days ago: the first two days are in the past.
    let twoDaysAgo = now.addingTimeInterval(-2 * 24 * 60 * 60)
    let days = WeatherRecording.tokyo.forecast(startingOn: twoDaysAgo, calendar: calendar).daily

    let next = try #require(
      SunnyLevel.mostlyClear.nextSunnyDay(in: days, now: now, calendar: calendar))
    #expect(next.daysAway == 0)
    #expect(calendar.isDate(next.day.date, inSameDayAs: now))
  }
}
