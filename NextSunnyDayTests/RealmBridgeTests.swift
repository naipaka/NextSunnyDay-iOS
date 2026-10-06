//
//  RealmBridgeTests.swift
//  NextSunnyDayTests
//
//  Covers the temporary WeatherKit-to-Realm mapping. Delete together with it in #94.
//

import Foundation
import Testing
import WeatherKit

@testable import NextSunnyDay

struct RealmBridgeTests {
  @Test func roundTripsLocationAndForecasts() {
    let location = ForecastLocation(name: "Tokyo", latitude: 35.68, longitude: 139.77)
    let forecasts = [
      DailyForecast(
        date: Date(timeIntervalSince1970: 1_800_000_000),
        condition: .mostlyClear,
        symbolName: "sun.min",
        highTemperature: Measurement(value: 21.5, unit: .celsius),
        lowTemperature: Measurement(value: 14, unit: .celsius),
        precipitationChance: 0.2
      )
    ]

    let entity = DailyWeatherForecastEntity(location: location, forecasts: forecasts)

    #expect(entity.location == location)
    #expect(entity.dailyForecasts == forecasts)
  }

  @Test func storesTemperaturesInCelsius() {
    let forecast = DailyForecast(
      date: Date(timeIntervalSince1970: 1_800_000_000),
      condition: .clear,
      symbolName: "sun.max",
      highTemperature: Measurement(value: 212, unit: .fahrenheit),
      lowTemperature: Measurement(value: 32, unit: .fahrenheit),
      precipitationChance: 0
    )

    let daily = Daily(forecast)

    #expect(abs((daily.temp?.max ?? 0) - 100) < 0.001)
    #expect(abs(daily.temp?.min ?? 1) < 0.001)
  }

  @Test func skipsDaysSavedByOpenWeather() {
    let weather = Weather()
    weather.id = 800
    weather.main = "Clear"
    let daily = Daily()
    daily.weather.append(weather)

    #expect(daily.dailyForecast == nil)
  }
}
