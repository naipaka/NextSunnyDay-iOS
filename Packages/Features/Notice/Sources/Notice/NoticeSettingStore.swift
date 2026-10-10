import AppGroup
public import Foundation

/// Keeps the notification setting in App Group `UserDefaults`, so the widget reads the same one
/// when it fetches.
///
/// Never migrated: the stored values must stay readable by every later version
/// (`NoticeSettingStoreTests` pins them).
///
/// `@unchecked` because `UserDefaults` is not marked `Sendable`, although it is thread-safe.
public struct NoticeSettingStore: @unchecked Sendable {
  static let isOnKey = "noticeOn"
  static let regionKey = "noticeRegion"
  /// Minutes after midnight.
  static let timeKey = "noticeTime"

  private let defaults: UserDefaults

  /// The store shared with the widget.
  public init() {
    self.init(defaults: AppGroupContainer.userDefaults)
  }

  public init(defaults: UserDefaults) {
    self.defaults = defaults
  }

  /// The stored setting, with the defaults for what the user hasn't changed.
  public func load() -> NoticeSetting {
    NoticeSetting(
      isOn: defaults.bool(forKey: Self.isOnKey),
      regionID: defaults.string(forKey: Self.regionKey),
      time: (defaults.object(forKey: Self.timeKey) as? Int).flatMap(NoticeTime.init(minutes:))
        ?? .default)
  }

  public func save(_ setting: NoticeSetting) {
    defaults.set(setting.isOn, forKey: Self.isOnKey)
    if let regionID = setting.regionID {
      defaults.set(regionID, forKey: Self.regionKey)
    } else {
      defaults.removeObject(forKey: Self.regionKey)
    }
    defaults.set(setting.time.minutes, forKey: Self.timeKey)
  }
}
