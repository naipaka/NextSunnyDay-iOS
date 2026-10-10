import Foundation
public import Weather

/// Which days count as sunny. The first four go from strictest to loosest, each counting
/// everything the stricter ones do; `laundry` stands apart. See "Sunny levels" in
/// `docs/design/spec.md`.
///
/// Stored by raw value, so don't rename the cases.
public enum SunnyLevel: String, Codable, CaseIterable, Sendable {
  /// Clear only.
  case clear
  /// Clear and mostly clear, the rule of version 1.
  case mostlyClear
  /// Up to partly cloudy.
  case partlyCloudy
  /// Any day without precipitation, storms, fog, smoke or dust, and with a precipitation chance
  /// under 30 %.
  case noRain
  /// A day to dry laundry outside: no rain all day, and a sunny, dry, calm daytime.
  case laundry

  public static let `default` = SunnyLevel.mostlyClear

  /// The four levels from strictest to loosest, without `laundry`.
  public static let cumulative: [SunnyLevel] = [.clear, .mostlyClear, .partlyCloudy, .noRain]

  /// The precipitation chance a day must stay under at `noRain`.
  static let noRainPrecipitationLimit = 0.3

  /// What the daytime (7:00–19:00) of a laundry day must stay under or within.
  static let laundryPrecipitationLimit = 0.2
  static let laundryHumidityLimit = 0.6
  static let laundryWindLimit = Measurement(value: 10, unit: UnitSpeed.metersPerSecond)

  /// Whether `day` counts as sunny at this level.
  public func counts(_ day: DayForecast) -> Bool {
    guard conditions.contains(day.condition) else { return false }
    switch self {
    case .clear, .mostlyClear, .partlyCloudy:
      return true
    case .noRain:
      return day.precipitationChance < Self.noRainPrecipitationLimit
    case .laundry:
      let daytime = day.daytime
      return SunnyLevel.partlyCloudy.conditions.contains(daytime.condition)
        && daytime.precipitationChance < Self.laundryPrecipitationLimit
        && daytime.minimumHumidity <= Self.laundryHumidityLimit
        && daytime.highWindSpeed < Self.laundryWindLimit
    }
  }

  /// The conditions of the whole day that count at this level. A laundry day also needs its
  /// daytime to be up to partly cloudy.
  public var conditions: Set<WeatherCondition> {
    switch self {
    case .clear:
      [.clear]
    case .mostlyClear:
      SunnyLevel.clear.conditions.union([.mostlyClear])
    case .partlyCloudy:
      SunnyLevel.mostlyClear.conditions.union([.partlyCloudy])
    case .noRain, .laundry:
      SunnyLevel.partlyCloudy.conditions.union([
        .mostlyCloudy, .cloudy, .haze, .breezy, .windy, .hot, .frigid,
      ])
    }
  }
}
