//
//  AppGroup.swift
//  NextSunnyDay
//

import Foundation

/// The App Group shared by the app and the widget.
enum AppGroup {
  static let identifier = "group.com.naipaka.NextSunnyDay"

  /// The root of the shared container.
  static var containerURL: URL {
    // Only `nil` when the App Group entitlement is missing, which is a build setup error.
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)!
  }

  /// Data that can be fetched again, such as the forecast.
  static var cachesDirectory: URL {
    containerURL.appending(path: "Library/Caches", directoryHint: .isDirectory)
  }

  /// Settings shared with the widget.
  static let userDefaults: UserDefaults = {
    // Only `nil` for the global domain or the app's own bundle identifier.
    UserDefaults(suiteName: identifier)!
  }()
}
