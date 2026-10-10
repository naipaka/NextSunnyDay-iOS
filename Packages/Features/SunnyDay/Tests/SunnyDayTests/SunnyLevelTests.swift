import Foundation
import SunnyDay
import Testing
import Weather
import WeatherTesting

struct SunnyLevelTests {
  private func day(_ condition: WeatherCondition, precipitation: Double = 0) -> DayForecast {
    var day = WeatherRecording.tokyo.recorded.daily[0]
    day.condition = condition
    day.precipitationChance = precipitation
    return day
  }

  @Test(arguments: [
    (SunnyLevel.clear, [WeatherCondition.clear]),
    (.mostlyClear, [.clear, .mostlyClear]),
    (.partlyCloudy, [.clear, .mostlyClear, .partlyCloudy]),
    (
      .noRain,
      [
        .clear, .mostlyClear, .partlyCloudy, .mostlyCloudy, .cloudy, .haze, .breezy, .windy, .hot,
        .frigid,
      ]
    ),
  ])
  func eachLevelCountsItsConditions(level: SunnyLevel, counted: [WeatherCondition]) {
    for condition in WeatherCondition.allCases {
      #expect(level.counts(day(condition)) == counted.contains(condition), "\(condition)")
    }
  }

  @Test func noRainNeedsAPrecipitationChanceUnder30Percent() {
    #expect(SunnyLevel.noRain.counts(day(.cloudy, precipitation: 0.29)))
    #expect(!SunnyLevel.noRain.counts(day(.cloudy, precipitation: 0.3)))
    #expect(!SunnyLevel.noRain.counts(day(.clear, precipitation: 0.5)))
  }

  @Test func otherLevelsIgnoreThePrecipitationChance() {
    #expect(SunnyLevel.mostlyClear.counts(day(.clear, precipitation: 0.5)))
  }

  /// A day that is a laundry day until a test changes one of its values.
  private func laundryDay(
    _ condition: WeatherCondition = .mostlyClear, daytime: WeatherCondition = .mostlyClear,
    precipitation: Double = 0.19, humidity: Double = 0.6, windMetersPerSecond: Double = 9.9
  ) -> DayForecast {
    var day = day(condition, precipitation: 0.6)
    day.daytime = DaytimeForecast(
      condition: daytime, precipitationChance: precipitation, minimumHumidity: humidity,
      highWindSpeed: Measurement(value: windMetersPerSecond, unit: .metersPerSecond))
    return day
  }

  @Test func laundryCountsASunnyDryCalmDaytime() {
    #expect(SunnyLevel.laundry.counts(laundryDay()))
    #expect(SunnyLevel.laundry.counts(laundryDay(daytime: .clear)))
    #expect(SunnyLevel.laundry.counts(laundryDay(daytime: .partlyCloudy)))
    #expect(!SunnyLevel.laundry.counts(laundryDay(daytime: .mostlyCloudy)))
    #expect(!SunnyLevel.laundry.counts(laundryDay(precipitation: 0.2)))
    #expect(!SunnyLevel.laundry.counts(laundryDay(humidity: 0.61)))
    #expect(!SunnyLevel.laundry.counts(laundryDay(windMetersPerSecond: 10)))
  }

  @Test func laundryNeedsNoRainAllDay() {
    // The whole day's precipitation chance doesn't matter, its condition does.
    #expect(SunnyLevel.laundry.counts(laundryDay(.cloudy)))
    #expect(!SunnyLevel.laundry.counts(laundryDay(.drizzle)))
    #expect(!SunnyLevel.laundry.counts(laundryDay(.foggy)))
  }

  @Test func laundryDaysInTheRecordings() {
    let tokyo = WeatherRecording.tokyo.recorded.daily.map(SunnyLevel.laundry.counts)
    let singapore = WeatherRecording.singapore.recorded.daily.map(SunnyLevel.laundry.counts)

    // The six sunny days, but not the 9th day: dry in the daytime, drizzle for the day.
    #expect(tokyo == [true, true, true, true, true, true, false, false, false, false])
    #expect(!singapore.contains(true))
  }

  @Test func cumulativeLevelsLeaveOutLaundry() {
    #expect(SunnyLevel.cumulative == SunnyLevel.allCases.filter { $0 != .laundry })
  }

  @Test func theDefaultIsTheRuleOfVersion1() {
    #expect(SunnyLevel.default == .mostlyClear)
  }

  @Test func rawValuesStayStable() {
    #expect(
      SunnyLevel.allCases.map(\.rawValue) == [
        "clear", "mostlyClear", "partlyCloudy", "noRain", "laundry",
      ])
  }
}
