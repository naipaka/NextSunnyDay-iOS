import Foundation

/// The App Group shared by the app and the widget: where both read and write settings and caches.
public enum AppGroupContainer {
  public static let identifier = "group.com.naipaka.NextSunnyDay"

  /// The root of the shared container.
  public static var url: URL {
    // Only `nil` when the App Group entitlement is missing, which is a build setup error.
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)!
  }

  /// Data that can be fetched again, such as forecasts.
  public static var cachesDirectory: URL {
    url.appending(path: "Library/Caches", directoryHint: .isDirectory)
  }

  /// Settings shared with the widget.
  public static var userDefaults: UserDefaults {
    // Only `nil` for the global domain or the app's own bundle identifier.
    UserDefaults(suiteName: identifier)!
  }
}
