import AppGroup
public import Foundation

/// Keeps the temperature unit setting in App Group `UserDefaults`, so the widget reads the same
/// one.
///
/// Never migrated: the stored value must stay readable by every later version
/// (`TemperatureUnitStoreTests` pins it).
///
/// `@unchecked` because `UserDefaults` is not marked `Sendable`, although it is thread-safe.
public struct TemperatureUnitStore: @unchecked Sendable {
  /// Where the setting is stored, for copying it to the watch.
  public static let key = "temperatureUnit"

  private let defaults: UserDefaults

  /// The store shared with the widget.
  public init() {
    self.init(defaults: AppGroupContainer.userDefaults)
  }

  public init(defaults: UserDefaults) {
    self.defaults = defaults
  }

  /// The stored setting, or the default before the user changes it.
  public func load() -> TemperatureUnitSetting {
    defaults.string(forKey: Self.key).flatMap(TemperatureUnitSetting.init) ?? .default
  }

  public func save(_ setting: TemperatureUnitSetting) {
    defaults.set(setting.rawValue, forKey: Self.key)
  }
}
