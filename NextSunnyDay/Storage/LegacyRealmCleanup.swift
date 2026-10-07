//
//  LegacyRealmCleanup.swift
//  NextSunnyDay
//

import Foundation

/// Deletes the Realm database that version 1 kept in the App Group container. Its data is not
/// migrated: after updating, the user picks the region again.
enum LegacyRealmCleanup {
  /// Removes `db.realm` and its companions (`.lock`, `.note`, `.management/`) from `directory`.
  /// Does nothing when they are already gone, so it is safe to call on every launch.
  static func run(in directory: URL = AppGroup.containerURL, fileManager: FileManager = .default) {
    guard
      let names = try? fileManager.contentsOfDirectory(
        atPath: directory.path(percentEncoded: false))
    else { return }
    for name in names where name.hasPrefix("db.realm") {
      try? fileManager.removeItem(at: directory.appending(path: name))
    }
  }
}
