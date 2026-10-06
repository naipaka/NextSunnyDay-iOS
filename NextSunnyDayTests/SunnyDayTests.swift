//
//  SunnyDayTests.swift
//  NextSunnyDayTests
//

import Foundation
import Testing
import WeatherKit

@testable import NextSunnyDay

struct SunnyDayTests {
  private let today = Date(timeIntervalSince1970: 1_800_000_000)

  private func day(_ offset: Int, _ condition: WeatherCondition) -> DailyForecast {
    .sample(
      date: today.addingTimeInterval(TimeInterval(offset) * 60 * 60 * 24), condition: condition)
  }

  @Test func onlyClearAndMostlyClearAreSunny() {
    let sunny = WeatherCondition.allCases.filter(\.isSunny)
    #expect(Set(sunny) == [.clear, .mostlyClear])
  }

  @Test func nextSunnyDayIsTheEarliestSunnyDay() {
    let forecasts = [day(3, .clear), day(0, .rain), day(2, .mostlyClear), day(1, .cloudy)]
    #expect(forecasts.nextSunnyDay == day(2, .mostlyClear))
  }

  @Test func nextSunnyDayIsNilWithoutSunnyDays() {
    let forecasts = [day(0, .rain), day(1, .partlyCloudy), day(2, .snow)]
    #expect(forecasts.nextSunnyDay == nil)
  }

  @Test func nextSunnyDayIsNilForEmptyForecast() {
    #expect([DailyForecast]().nextSunnyDay == nil)
  }
}
