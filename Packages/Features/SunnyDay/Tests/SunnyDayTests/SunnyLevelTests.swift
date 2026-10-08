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

  @Test func theDefaultIsTheRuleOfVersion1() {
    #expect(SunnyLevel.default == .mostlyClear)
  }

  @Test func rawValuesStayStable() {
    #expect(
      SunnyLevel.allCases.map(\.rawValue) == ["clear", "mostlyClear", "partlyCloudy", "noRain"])
  }
}
