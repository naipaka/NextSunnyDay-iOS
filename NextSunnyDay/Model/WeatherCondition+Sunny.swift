//
//  WeatherCondition+Sunny.swift
//  NextSunnyDay
//

import WeatherKit

extension WeatherCondition {
  /// Whether a day with this condition counts as sunny.
  ///
  /// Clear and mostly clear, matching the OpenWeather rule of version 1 (800 clear sky,
  /// 801 few clouds). The definition shown to users is decided in #93.
  var isSunny: Bool {
    switch self {
    case .clear, .mostlyClear:
      true
    default:
      false
    }
  }
}
