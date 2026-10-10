public import CoreLocation
import MapKit

/// Searches with MapKit: completions while typing, then the completion's coordinate.
public struct MapKitPlaceSearch: PlaceSearching {
  /// How long to wait for the name of a coordinate.
  private let nameTimeout: Duration

  /// - Parameter nameTimeout: How long `placeName(at:)` waits before it gives up with `nil`. The
  ///   name is only a label for the current location, so a fetch shouldn't wait for it long.
  public init(nameTimeout: Duration = .seconds(10)) {
    self.nameTimeout = nameTimeout
  }

  public func completions(for query: String) async throws -> [PlaceCompletion] {
    let request = await CompletionRequest()
    return try await withTaskCancellationHandler {
      try await request.results(for: query)
    } onCancel: {
      Task { @MainActor in request.cancel() }
    }
  }

  public func place(for completion: PlaceCompletion) async throws -> Place {
    let request =
      if let source = completion.source {
        MKLocalSearch.Request(completion: source.completion)
      } else {
        MKLocalSearch.Request(naturalLanguageQuery: "\(completion.title) \(completion.subtitle)")
      }
    let response = try await MKLocalSearch(request: request).start()
    guard let item = response.mapItems.first else { throw PlaceSearchError.notFound }
    return Place(name: completion.title, coordinate: item.location.coordinate)
  }

  /// The city of a coordinate, or `nil` when MapKit has none or doesn't answer within the
  /// timeout. The request is cancelled when it times out.
  public func placeName(at coordinate: CLLocationCoordinate2D) async throws -> String? {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
    let box = RequestBox(request: request)
    return try await withTimeout(nameTimeout) {
      try await withTaskCancellationHandler {
        let item = try await box.request.mapItems.first
        return item?.addressRepresentations?.cityWithContext(.short)
          ?? item?.addressRepresentations?.cityName
      } onCancel: {
        box.request.cancel()
      }
    }
  }
}

/// Lets the cancellation handler cancel the request from another task. `@unchecked` because
/// `MKReverseGeocodingRequest` has no `Sendable` annotation; `cancel()` may be called from any
/// thread.
private struct RequestBox: @unchecked Sendable {
  let request: MKReverseGeocodingRequest
}

extension PlaceCompletion {
  /// MapKit's completion, kept so the place is found exactly as MapKit suggested it.
  /// `@unchecked` because `MKLocalSearchCompletion` is an immutable object without a `Sendable`
  /// annotation.
  struct Source: @unchecked Sendable {
    let completion: MKLocalSearchCompletion
  }
}

/// One query to `MKLocalSearchCompleter`, which answers through its delegate on the main thread.
@MainActor
private final class CompletionRequest: NSObject, MKLocalSearchCompleterDelegate {
  private let completer = MKLocalSearchCompleter()
  private var continuation: CheckedContinuation<[PlaceCompletion], any Error>?

  override init() {
    super.init()
    completer.resultTypes = .address
    // Areas only: prefectures, cities, wards and towns, not street addresses or buildings.
    completer.addressFilter = MKAddressFilter(
      including: [.administrativeArea, .subAdministrativeArea, .locality, .subLocality])
    completer.delegate = self
  }

  func results(for query: String) async throws -> [PlaceCompletion] {
    try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      completer.queryFragment = query
    }
  }

  func cancel() {
    completer.cancel()
    finish(.failure(CancellationError()))
  }

  nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    let results = completer.results.map {
      PlaceCompletion(title: $0.title, subtitle: $0.subtitle, source: .init(completion: $0))
    }
    MainActor.assumeIsolated {
      finish(.success(results))
    }
  }

  nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error)
  {
    MainActor.assumeIsolated {
      finish(.failure(error))
    }
  }

  private func finish(_ result: Result<[PlaceCompletion], any Error>) {
    continuation?.resume(with: result)
    continuation = nil
  }
}
