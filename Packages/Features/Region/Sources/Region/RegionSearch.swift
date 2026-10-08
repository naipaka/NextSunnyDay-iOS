import Foundation
import PlaceSearch

/// Finds regions by name while the user types, and turns the one they pick into a region.
public struct RegionSearch: Sendable {
  private let places: any PlaceSearching

  /// Searches with MapKit.
  public init() {
    self.init(places: MapKitPlaceSearch())
  }

  public init(places: any PlaceSearching) {
    self.places = places
  }

  /// Regions whose names match `query`. Empty for a query of only spaces.
  public func candidates(for query: String) async throws -> [RegionCandidate] {
    let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return [] }
    return try await places.completions(for: query).map(RegionCandidate.init)
  }

  /// The region `candidate` stands for, with its coordinate and a new ID.
  public func region(for candidate: RegionCandidate) async throws -> SavedRegion {
    let place = try await places.place(for: candidate.completion)
    return .place(name: place.name, coordinate: place.coordinate)
  }
}

/// A search result: a place name and where it is.
public struct RegionCandidate: Identifiable, Hashable, Sendable {
  public var id: String { completion.id }
  public var name: String { completion.title }
  /// Where the place is, such as the prefecture.
  public var area: String { completion.subtitle }

  let completion: PlaceCompletion
}
