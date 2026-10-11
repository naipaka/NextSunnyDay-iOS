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
  }

  @Test func todayIsNeverTheAnswer() throws {
    let days = WeatherRecording.tokyo.forecast(startingOn: now, calendar: calendar).daily
    #expect(SunnyLevel.mostlyClear.counts(days[0]))

    let next = try #require(
      SunnyLevel.mostlyClear.nextSunnyDay(in: days, now: now, calendar: calendar))
    #expect(next.daysAway == 1)
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
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
    #expect(next.daysAway == 1)
    #expect(calendar.isDate(next.day.date, inSameDayAs: tomorrow))
  }

  @Test func theRunLastsWhileTheDaysCount() throws {
    let days = WeatherRecording.tokyo.forecast(startingOn: now, calendar: calendar).daily

    // Tokyo is clear or mostly clear for six days, then drizzle.
    let next = try #require(
      SunnyLevel.mostlyClear.nextSunnyDay(in: days, now: now, calendar: calendar))
    #expect(next.lastsMoreThanADay)
    #expect(next.lastDay.date == days[5].date)
    #expect(days[6].condition == .drizzle)
  }

  @Test func aRunOfOneDayEndsOnTheAnswer() throws {
    let days = WeatherRecording.tokyo.forecast(startingOn: now, calendar: calendar).daily

    // Only the second day is clear.
    let next = try #require(SunnyLevel.clear.nextSunnyDay(in: days, now: now, calendar: calendar))
    #expect(!next.lastsMoreThanADay)
    #expect(next.lastDay == next.day)
  }

  @Test func theRunStopsAtTheEndOfTheForecast() throws {
    // Los Angeles turns clear on its seventh day and stays clear to the end.
    let days = WeatherRecording.losAngeles.forecast(startingOn: now, calendar: calendar).daily
    let twoDaysOn = calendar.date(byAdding: .day, value: 2, to: now)!

    let next = try #require(
      SunnyLevel.mostlyClear.nextSunnyDay(in: days, now: twoDaysOn, calendar: calendar))
    #expect(next.lastDay.date == days.last?.date)
  }
}
