public import CoreLocation
import MapKit

/// Searches with MapKit: completions while typing, then the completion's coordinate.
public struct MapKitPlaceSearch: PlaceSearching {
  public init() {}

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

  public func placeName(at coordinate: CLLocationCoordinate2D) async throws -> String? {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
    let item = try await request.mapItems.first
    return item?.addressRepresentations?.cityWithContext(.short)
      ?? item?.addressRepresentations?.cityName
  }
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
