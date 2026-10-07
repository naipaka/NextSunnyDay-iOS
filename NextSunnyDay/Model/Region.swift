//
//  Region.swift
//  NextSunnyDay
//

import Foundation

// MARK: - Region
/// A region the user chose to see the forecast for.
///
/// Stored in `UserDefaults` as JSON without migrations, so keep the encoded form stable
/// (`SettingsStoreTests` pins it).
struct Region: Codable, Equatable, Identifiable, Sendable {
  enum Kind: Codable, Equatable, Sendable {
    /// The device location. It is resolved with Core Location when fetching.
    case currentLocation
    /// A place picked by search.
    case place(ForecastLocation)

    private enum PlaceCodingKeys: String, CodingKey {
      case _0 = "location"
    }
  }

  /// Fixed when the region is added. Cached forecasts are keyed by it.
  var id: String
  var kind: Kind

  /// The ID of the current location, which is the same every time it is added.
  static let currentLocationID = "current-location"

  static var currentLocation: Region {
    Region(id: currentLocationID, kind: .currentLocation)
  }

  /// A searched place with a new ID.
  static func place(_ location: ForecastLocation) -> Region {
    Region(id: UUID().uuidString, kind: .place(location))
  }
}

// MARK: - Location
extension Region {
  /// The location of a searched place, or `nil` for the current location, which is only known
  /// when fetching.
  var location: ForecastLocation? {
    if case .place(let location) = kind { location } else { nil }
  }

  /// Whether `snapshot` was fetched for this region. Any snapshot matches the current location.
  func matches(_ snapshot: ForecastSnapshot) -> Bool {
    location.map { $0 == snapshot.location } ?? true
  }
}

// MARK: - SunnyLevel
/// Which days count as sunny, from strictest to loosest. The levels are cumulative; see
/// "Sunny levels" in `docs/design/spec.md`. Stored by raw value, so don't rename the cases.
enum SunnyLevel: String, Codable, CaseIterable, Sendable {
  /// Clear only.
  case clear
  /// Clear and mostly clear, the rule of version 1.
  case mostlyClear
  /// Up to partly cloudy.
  case partlyCloudy
  /// Any day without rain, snow, storms, fog or dust, and a precipitation chance under 30 %.
  case noRain

  static let `default` = SunnyLevel.mostlyClear
}
