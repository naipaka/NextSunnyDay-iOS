public import Foundation

/// Which unit temperatures are shown in: the system's (Settings > General > Language & Region >
/// Temperature, which follows the region until the user changes it), or one the user picks in
/// the app, like Apple's Weather app.
///
/// The cases are in the order the Weather app lists them.
public enum TemperatureUnitSetting: String, CaseIterable, Sendable {
  case celsius
  case fahrenheit
  case system

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
