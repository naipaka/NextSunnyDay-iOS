import CoreLocation
import Location

/// A `LocationProviding` that answers with a fixed coordinate or error.
public struct FakeLocationProvider: LocationProviding {
  private let result: Result<CLLocationCoordinate2D, LocationError>

  /// Minato, Tokyo, where the weather recordings were made.
  public init(_ coordinate: CLLocationCoordinate2D = .minato) {
    result = .success(coordinate)
  }

  public init(error: LocationError) {
    result = .failure(error)
  }

  /// The user doesn't allow location access.
  public static let denied = FakeLocationProvider(error: .denied)

  public func currentCoordinate() async throws -> CLLocationCoordinate2D {
    try result.get()
  }
}

extension CLLocationCoordinate2D {
  /// Minato, Tokyo.
  public static let minato = CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)
}
