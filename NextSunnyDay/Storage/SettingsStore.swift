//
//  SettingsStore.swift
//  NextSunnyDay
//

import Foundation

/// The user's settings, kept in App Group `UserDefaults` so the widget reads the same values.
///
/// There are no migrations: the stored format must stay readable by every later version.
/// Regions are a list from the start, although the app keeps only one for now.
///
/// `@unchecked` because `UserDefaults` is not marked `Sendable`, although it is thread-safe.
struct SettingsStore: @unchecked Sendable {
  private enum Key {
    static let regions = "regions"
    static let sunnyLevel = "sunnyLevel"
  }

  let defaults: UserDefaults

  init(defaults: UserDefaults = AppGroup.userDefaults) {
    self.defaults = defaults
  }

  /// Empty until the user picks a region. Stored as JSON.
  var regions: [Region] {
    get {
      defaults.data(forKey: Key.regions)
        .flatMap { try? JSONDecoder().decode([Region].self, from: $0) } ?? []
    }
    nonmutating set {
      if !newValue.isEmpty, let data = try? JSONEncoder().encode(newValue) {
        defaults.set(data, forKey: Key.regions)
      } else {
        defaults.removeObject(forKey: Key.regions)
      }
    }
  }

  var sunnyLevel: SunnyLevel {
    get {
      defaults.string(forKey: Key.sunnyLevel).flatMap(SunnyLevel.init) ?? .default
    }
    nonmutating set {
      defaults.set(newValue.rawValue, forKey: Key.sunnyLevel)
    }
  }
}
