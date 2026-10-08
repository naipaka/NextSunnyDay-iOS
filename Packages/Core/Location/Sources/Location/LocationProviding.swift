public import CoreLocation

/// Finds where the device is. `CoreLocationProvider` is the real one; `LocationTesting` has a
/// fake.
public protocol LocationProviding: Sendable {
  /// The current location, asking for permission when needed.
  func currentCoordinate() async throws -> CLLocationCoordinate2D
}

public enum LocationError: Error, Equatable, Sendable {
  /// The user denied access, or location services are off or restricted.
  case denied
  /// No location came in time.
  case unavailable
}
