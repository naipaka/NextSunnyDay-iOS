//
//  DailyForecast.swift
//  NextSunnyDay
//

import Foundation
import WeatherKit

// MARK: - DailyForecast
/// One day of weather forecast, independent of the weather API and of storage.
struct DailyForecast: Codable, Equatable, Sendable {
  var date: Date
  var condition: WeatherCondition
  /// An SF Symbol name for the condition, e.g. `cloud.sun`.
  var symbolName: String
  var highTemperature: Measurement<UnitTemperature>
  var lowTemperature: Measurement<UnitTemperature>
  /// The chance of precipitation, from 0 to 1.
  var precipitationChance: Double
  /// `nil` when the sun doesn't rise that day (polar night).
  var sunrise: Date?
  /// `nil` when the sun doesn't set that day (midnight sun).
  var sunset: Date?
  var uvIndex: Int
  var windSpeed: Measurement<UnitSpeed>
  /// The direction the wind blows from.
  var windDirection: Measurement<UnitAngle>
}

// MARK: - ForecastLocation
/// A place the forecast is fetched for.
struct ForecastLocation: Codable, Equatable, Sendable {
  var name: String
  var latitude: Double
  var longitude: Double
}

// MARK: - Next sunny day
extension Sequence<DailyForecast> {
  /// The earliest sunny day, or `nil` if no day is sunny.
  var nextSunnyDay: DailyForecast? {
    filter(\.condition.isSunny).min { $0.date < $1.date }
  }
}

// MARK: - Sample
extension DailyForecast {
  /// Sample data for previews and tests.
  static func sample(
    date: Date, condition: WeatherCondition, symbolName: String? = nil,
    high: Double = 11, low: Double = 2
  ) -> DailyForecast {
    DailyForecast(
      date: date,
      condition: condition,
      symbolName: symbolName ?? (condition.isSunny ? "sun.max" : "cloud"),
      highTemperature: Measurement(value: high, unit: .celsius),
      lowTemperature: Measurement(value: low, unit: .celsius),
      precipitationChance: 0,
      sunrise: date.addingTimeInterval(6 * 60 * 60),
      sunset: date.addingTimeInterval(17 * 60 * 60),
      uvIndex: 3,
      windSpeed: Measurement(value: 3, unit: .metersPerSecond),
      windDirection: Measurement(value: 0, unit: .degrees)
    )
  }
}
