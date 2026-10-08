public import CoreLocation
import Foundation

/// A region the user chose to see the forecast for.
///
/// Stored in `UserDefaults` as JSON without migrations, so keep the encoded form stable
/// (`RegionStoreTests` pins it).
public struct SavedRegion: Codable, Equatable, Identifiable, Sendable {
  public enum Kind: Codable, Equatable, Sendable {
    /// The device location, found when fetching.
    case currentLocation
    /// A place picked by search.
    case place(name: String, latitude: Double, longitude: Double)
  }

  /// Fixed when the region is added. Cached forecasts are keyed by it.
  public var id: String
  public var kind: Kind

  public init(id: String, kind: Kind) {
    self.id = id
    self.kind = kind
  }

  /// The ID of the current location, the same every time it is chosen, so it keeps one cached
  /// forecast.
  public static let currentLocationID = "current-location"

  public static var currentLocation: SavedRegion {
    SavedRegion(id: currentLocationID, kind: .currentLocation)
  }

  /// A searched place with a new ID.
  public static func place(name: String, coordinate: CLLocationCoordinate2D) -> SavedRegion {
    SavedRegion(
      id: UUID().uuidString,
      kind: .place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude))
  }

  /// The name of a searched place, or `nil` for the current location, which is only known when
  /// fetching.
  public var placeName: String? {
    if case .place(let name, _, _) = kind { name } else { nil }
  }
}
