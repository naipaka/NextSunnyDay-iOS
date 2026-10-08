public import Weather

/// Which days count as sunny, from strictest to loosest. Each level counts everything the
/// stricter ones do; see "Sunny levels" in `docs/design/spec.md`.
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

  public static let `default` = SunnyLevel.mostlyClear

  /// The precipitation chance a day must stay under at `noRain`.
  static let noRainPrecipitationLimit = 0.3

  /// Whether `day` counts as sunny at this level.
  public func counts(_ day: DayForecast) -> Bool {
    guard conditions.contains(day.condition) else { return false }
    return self != .noRain || day.precipitationChance < Self.noRainPrecipitationLimit
  }

  /// The conditions that count at this level.
  public var conditions: Set<WeatherCondition> {
    switch self {
    case .clear:
      [.clear]
    case .mostlyClear:
      SunnyLevel.clear.conditions.union([.mostlyClear])
    case .partlyCloudy:
      SunnyLevel.mostlyClear.conditions.union([.partlyCloudy])
    case .noRain:
      SunnyLevel.partlyCloudy.conditions.union([
        .mostlyCloudy, .cloudy, .haze, .breezy, .windy, .hot, .frigid,
      ])
    }
  }
}
