public import CoreLocation
import Location
import PlaceSearch

/// Finds where a region is when its forecast is fetched: a searched place is where it was saved;
/// the current location is looked up and named at that moment.
public struct RegionLocator: Sendable {
  private let location: any LocationProviding
  private let places: any PlaceSearching

  /// Uses Core Location and MapKit.
  public init() {
    self.init(location: CoreLocationProvider(), places: MapKitPlaceSearch())
  }

  /// Uses Core Location and MapKit, waiting at most `locationTimeout` for the location: the
  /// widget has only a few seconds to build its timeline.
  public init(locationTimeout: Duration) {
    self.init(location: CoreLocationProvider(timeout: locationTimeout), places: MapKitPlaceSearch())
  }

  public init(location: any LocationProviding, places: any PlaceSearching) {
    self.location = location
    self.places = places
  }

  /// The region's coordinate and name. The name of the current location is `nil` when it can't
  /// be found; the coordinate is still usable.
  public func locate(_ region: SavedRegion) async throws(RegionLocatorError) -> LocatedRegion {
    switch region.kind {
    case .place(let name, let latitude, let longitude):
      return LocatedRegion(
        name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    case .currentLocation:
      let coordinate: CLLocationCoordinate2D
      do {
        coordinate = try await location.currentCoordinate()
      } catch LocationError.denied {
        throw .locationDenied
      } catch {
        throw .locationUnavailable
      }
      let name = try? await places.placeName(at: coordinate)
      return LocatedRegion(name: name ?? nil, coordinate: coordinate)
    }
  }
}

/// Where a region is at the moment.
public struct LocatedRegion: Sendable {
  public var name: String?
  public var coordinate: CLLocationCoordinate2D
}

public enum RegionLocatorError: Error, Equatable, Sendable {
  /// The user doesn't allow the app to use their location.
  case locationDenied
  /// The device couldn't find its location.
  case locationUnavailable
}
