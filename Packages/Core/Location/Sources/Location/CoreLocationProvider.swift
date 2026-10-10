public import CoreLocation

/// Gets the location once with Core Location, asking for "when in use" permission.
public struct CoreLocationProvider: LocationProviding {
  /// How long to wait for a location.
  private let timeout: Duration

  public init(timeout: Duration = .seconds(15)) {
    self.timeout = timeout
  }

  public func currentCoordinate() async throws -> CLLocationCoordinate2D {
    #if !os(macOS)
      // The session asks for permission and keeps it while the updates run. macOS, where the
      // package's tests run, has no `CLServiceSession`.
      let session = CLServiceSession(authorization: .whenInUse)
      defer { session.invalidate() }
    #endif
    let coordinate = try await withTimeout(timeout) {
      for try await update in CLLocationUpdate.liveUpdates() {
        if update.authorizationDenied || update.authorizationDeniedGlobally
          || update.authorizationRestricted
        {
          throw LocationError.denied
        }
        if let location = update.location { return location.coordinate }
      }
      return nil
    }
    guard let coordinate else { throw LocationError.unavailable }
    return coordinate
  }
}

/// The result of `operation`, or `nil` if `timeout` passes first, which cancels it.
func withTimeout<T: Sendable>(
  _ timeout: Duration, operation: @escaping @Sendable () async throws -> T?
) async throws -> T? {
  try await withThrowingTaskGroup(of: T?.self) { group in
    group.addTask { try await operation() }
    group.addTask {
      try await Task.sleep(for: timeout)
      return nil
    }
    let first = try await group.next() ?? nil
    group.cancelAll()
    return first
  }
}
