//
//  HourlyForecast.swift
//  NextSunnyDay
//

import Foundation
import WeatherKit

// MARK: - HourlyForecast
/// One hour of weather forecast, independent of the weather API and of storage.
struct HourlyForecast: Codable, Equatable, Sendable {
  /// The start of the hour.
  var date: Date
  var condition: WeatherCondition
  /// An SF Symbol name for the condition, e.g. `cloud.moon`.
  var symbolName: String
  var isDaylight: Bool
  var temperature: Measurement<UnitTemperature>
  /// The chance of precipitation, from 0 to 1.
  var precipitationChance: Double
}

// MARK: - Sample
extension HourlyForecast {
  /// Sample data for previews and tests.
  static func sample(
    date: Date, condition: WeatherCondition, temperature: Double = 8
  ) -> HourlyForecast {
    HourlyForecast(
      date: date,
      condition: condition,
      symbolName: condition.isSunny ? "sun.max" : "cloud",
      isDaylight: true,
      temperature: Measurement(value: temperature, unit: .celsius),
      precipitationChance: 0
    )
  }
}
