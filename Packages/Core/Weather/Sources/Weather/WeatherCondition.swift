import Foundation

/// The weather condition of a day or an hour.
///
/// The module's own copy of WeatherKit's conditions, so that rules built on them don't depend on
/// the data source. Stored in cached forecasts by raw value, so don't rename the cases.
public enum WeatherCondition: String, Codable, CaseIterable, Sendable {
  case blizzard
  case blowingDust
  case blowingSnow
  case breezy
  case clear
  case cloudy
  case drizzle
  case flurries
  case foggy
  case freezingDrizzle
  case freezingRain
  case frigid
  case hail
  case haze
  case heavyRain
  case heavySnow
  case hot
  case hurricane
  case isolatedThunderstorms
  case mostlyClear
  case mostlyCloudy
  case partlyCloudy
  case rain
  case scatteredThunderstorms
  case sleet
  case smoky
  case snow
  case strongStorms
  case sunFlurries
  case sunShowers
  case thunderstorms
  case tropicalStorm
  case windy
  case wintryMix
  /// A condition added to WeatherKit after this list was written.
  case unknown
}
