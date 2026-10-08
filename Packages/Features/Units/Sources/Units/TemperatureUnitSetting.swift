public import Foundation

/// Which unit temperatures are shown in: the system's (Settings > General > Language & Region >
/// Temperature, which follows the region until the user changes it), or one the user picks in
/// the app, like Apple's Weather app.
public enum TemperatureUnitSetting: String, CaseIterable, Sendable {
  case system
  case celsius
  case fahrenheit

  public static let `default`: TemperatureUnitSetting = .system

  /// The unit to show temperatures in for `locale`, which gives the system's unit.
  public func unit(for locale: Locale) -> UnitTemperature {
    switch self {
    case .system: UnitTemperature(forLocale: locale, usage: .weather)
    case .celsius: .celsius
    case .fahrenheit: .fahrenheit
    }
  }
}
