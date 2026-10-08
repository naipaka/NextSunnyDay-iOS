import AppGroup
public import Foundation

/// Keeps the sunny level in App Group `UserDefaults`, so the widget reads the same one.
///
/// Never migrated: the stored value must stay readable by every later version
/// (`SunnyLevelStoreTests` pins it).
///
/// `@unchecked` because `UserDefaults` is not marked `Sendable`, although it is thread-safe.
public struct SunnyLevelStore: @unchecked Sendable {
  static let key = "sunnyLevel"

  private let defaults: UserDefaults

  /// The store shared with the widget.
  public init() {
    self.init(defaults: AppGroupContainer.userDefaults)
  }

  public init(defaults: UserDefaults) {
    self.defaults = defaults
  }

  /// The stored level, or the default before the user changes it.
  public func load() -> SunnyLevel {
    defaults.string(forKey: Self.key).flatMap(SunnyLevel.init) ?? .default
  }

  public func save(_ level: SunnyLevel) {
    defaults.set(level.rawValue, forKey: Self.key)
  }
}
