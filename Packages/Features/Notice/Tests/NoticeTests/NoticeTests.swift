import Foundation
import Notice
import Testing
import Weather

struct NoticeTests {
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    return calendar
  }()

  let on = NoticeSetting(isOn: true, regionID: nil, time: .default)

  /// 8 October 2026 at `hour` in Tokyo.
  func october8(hour: Int) -> Date {
    calendar.date(from: DateComponents(year: 2026, month: 10, day: 8, hour: hour))!
  }

  /// Days from 8 October, one per letter: `s` sunny, `r` not.
  func days(_ pattern: String) -> [DayForecast] {
    pattern.enumerated().map { offset, letter in
      DayForecast(
        date: calendar.date(byAdding: .day, value: offset, to: october8(hour: 0))!,
        condition: letter == "s" ? .clear : .rain, symbolName: "",
        highTemperature: .init(value: 24, unit: .celsius),
        lowTemperature: .init(value: 16, unit: .celsius), precipitationChance: 0, sunrise: nil,
        sunset: nil, uvIndex: 0, windSpeed: .init(value: 0, unit: .kilometersPerHour),
        windDirection: .init(value: 0, unit: .degrees),
        daytime: DaytimeForecast(
          condition: .clear, precipitationChance: 0, minimumHumidity: 0.5,
          highWindSpeed: .init(value: 0, unit: .kilometersPerHour)))
    }
  }

  func notices(
    _ pattern: String, setting: NoticeSetting? = nil, fetchedAt: Date? = nil, now: Date? = nil
  ) -> [Notice] {
    let now = now ?? october8(hour: 8)
    return (setting ?? on).notices(
      in: days(pattern), fetchedAt: fetchedAt ?? now, now: now, calendar: calendar,
      isSunny: { $0.condition == .clear })
  }

  func day(of date: Date) -> Int {
    calendar.component(.day, from: date)
  }

  @Test func notifiesTheEveningBeforeASunnyDay() throws {
    let notice = try #require(notices("rs").first)

    #expect(notice.date == october8(hour: 19))
    #expect(day(of: notice.day.date) == 9)
  }

  @Test func notifiesOnceWhenASunnySpellStarts() {
    #expect(notices("rsss").count == 1)
  }

  @Test func staysQuietWhileItIsSunny() {
    // Today is sunny and so is tomorrow.
    #expect(notices("ss").isEmpty)
  }

  @Test func eachSpellIsAnnounced() {
    // Fetched in the morning: the 8th and 9th evenings are within two days.
    #expect(notices("rsrs").map { day(of: $0.day.date) } == [9])
    #expect(notices("rsrs", fetchedAt: october8(hour: 20)).map { day(of: $0.day.date) } == [9, 11])
  }

  @Test func atTheChosenTime() throws {
    let setting = NoticeSetting(isOn: true, regionID: nil, time: NoticeTime(hour: 7, minute: 30))

    let notice = try #require(notices("rrs", setting: setting).first)

    #expect(notice.date == calendar.date(byAdding: .minute, value: 30, to: october8(hour: 7 + 24)))
  }

  @Test func nothingWhenOff() {
    #expect(notices("rs", setting: .default).isEmpty)
  }

  @Test func nothingThatHasGoneOut() {
    #expect(notices("rs", now: october8(hour: 19)).isEmpty)
    #expect(notices("rs", now: october8(hour: 18)).count == 1)
  }

  /// A notification goes out at most two days after its forecast was fetched.
  @Test func nothingFromAnOldForecast() {
    let fetchedAt = october8(hour: 8)

    // The evening of the 10th is 59 hours after the fetch.
    #expect(notices("rrrs", fetchedAt: fetchedAt).isEmpty)
    // The evening of the 9th is 35 hours after it.
    #expect(notices("rrs", fetchedAt: fetchedAt).count == 1)
    // The evening of the 10th, two days after a fetch at 19:00 on the 8th.
    #expect(notices("rrrs", fetchedAt: october8(hour: 19)).count == 1)
  }

  @Test func theFirstDayNeedsADayBefore() {
    // Whether the day before the first day was sunny isn't known.
    #expect(notices("s").isEmpty)
  }
}
