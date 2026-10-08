import CoreLocation
import PlaceSearch

/// A `PlaceSearching` over a fixed list of places, matched by prefix.
public struct FakePlaceSearch: PlaceSearching {
  private let places: [(completion: PlaceCompletion, coordinate: CLLocationCoordinate2D)]
  private let nameAtCoordinate: String?

  /// - Parameters:
  ///   - places: The places search can find.
  ///   - nameAtCoordinate: The name `placeName(at:)` gives any coordinate.
  public init(
    places: [(completion: PlaceCompletion, coordinate: CLLocationCoordinate2D)] = Self.samples,
    nameAtCoordinate: String? = "東京都港区"
  ) {
    self.places = places
    self.nameAtCoordinate = nameAtCoordinate
  }

  public func completions(for query: String) async throws -> [PlaceCompletion] {
    places.map(\.completion).filter { $0.title.hasPrefix(query) }
  }

  public func place(for completion: PlaceCompletion) async throws -> Place {
    guard let match = places.first(where: { $0.completion == completion }) else {
      throw PlaceSearchError.notFound
    }
    return Place(name: completion.title, coordinate: match.coordinate)
  }

  public func placeName(at coordinate: CLLocationCoordinate2D) async throws -> String? {
    nameAtCoordinate
  }

  public static let samples: [(completion: PlaceCompletion, coordinate: CLLocationCoordinate2D)] = [
    (
      PlaceCompletion(title: "港区", subtitle: "東京都"),
      CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)
    ),
    (
      PlaceCompletion(title: "港区", subtitle: "大阪府大阪市"),
      CLLocationCoordinate2D(latitude: 34.664, longitude: 135.461)
    ),
    (
      PlaceCompletion(title: "札幌市", subtitle: "北海道"),
      CLLocationCoordinate2D(latitude: 43.062, longitude: 141.354)
    ),
  ]
}
