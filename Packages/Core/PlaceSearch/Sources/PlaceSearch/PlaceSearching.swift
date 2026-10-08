public import CoreLocation

/// Searches places by name and names places by coordinate. `MapKitPlaceSearch` is the real one;
/// `PlaceSearchTesting` has a fake.
public protocol PlaceSearching: Sendable {
  /// Places whose names match what the user has typed so far.
  func completions(for query: String) async throws -> [PlaceCompletion]
  /// The place a completion stands for, with its coordinate.
  func place(for completion: PlaceCompletion) async throws -> Place
  /// A name for the place at `coordinate`, such as 「東京都港区」, or `nil` if there is none.
  func placeName(at coordinate: CLLocationCoordinate2D) async throws -> String?
}

/// A search result while typing.
public struct PlaceCompletion: Identifiable, Hashable, Sendable {
  public var id: String { "\(title)\n\(subtitle)" }
  public var title: String
  /// Where the place is, such as the prefecture and country.
  public var subtitle: String

  /// What `MapKitPlaceSearch` needs to find the place again.
  let source: Source?

  public init(title: String, subtitle: String) {
    self.title = title
    self.subtitle = subtitle
    source = nil
  }

  init(title: String, subtitle: String, source: Source) {
    self.title = title
    self.subtitle = subtitle
    self.source = source
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(subtitle)
  }
}

/// A named place with its coordinate.
public struct Place: Equatable, Sendable {
  public var name: String
  public var coordinate: CLLocationCoordinate2D

  public init(name: String, coordinate: CLLocationCoordinate2D) {
    self.name = name
    self.coordinate = coordinate
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.name == rhs.name && lhs.coordinate.latitude == rhs.coordinate.latitude
      && lhs.coordinate.longitude == rhs.coordinate.longitude
  }
}

public enum PlaceSearchError: Error, Equatable, Sendable {
  /// The completion no longer leads to a place.
  case notFound
}
