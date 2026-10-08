import CoreLocation
import Forecast
import Foundation
import LocationTesting
import PlaceSearchTesting
import Region
import Testing
import WeatherTesting

@testable import NextSunnyDay

@MainActor
final class RegionForecastTests {
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "RegionForecastTests-\(UUID().uuidString)", directoryHint: .isDirectory)
  private let osaka = SavedRegion.place(
    name: "大阪市", coordinate: CLLocationCoordinate2D(latitude: 34.702, longitude: 135.496))

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  private var cache: ForecastCache { ForecastCache(directory: directory) }

  private func regionForecast(
    _ weather: FakeWeatherProvider, location: FakeLocationProvider = FakeLocationProvider(),
    placeName: String? = "東京都港区"
  ) -> RegionForecast {
    RegionForecast(
      updater: ForecastUpdater(weather: weather, cache: cache),
      locator: RegionLocator(
        location: location, places: FakePlaceSearch(nameAtCoordinate: placeName)))
  }

  /// A forecast cached for `region`, fetched `age` ago and expiring an hour after that.
  private func cacheForecast(for region: SavedRegion, age: TimeInterval) async throws
    -> CachedForecast
  {
    let fetchedAt = Date.now.addingTimeInterval(-age)
    let cached = CachedForecast(
      regionID: region.id, placeName: region.placeName,
      coordinate: CLLocationCoordinate2D(latitude: 34.702, longitude: 135.496),
      fetchedAt: fetchedAt,
      forecast: WeatherRecording.tokyo.forecast(expiringAt: fetchedAt.addingTimeInterval(3600)))
    try await cache.save(cached)
    return cached
  }

  @Test func showsAFreshCacheWithoutFetching() async throws {
    let cached = try await cacheForecast(for: osaka, age: 60)
    let model = regionForecast(FakeWeatherProvider(error: URLError(.notConnectedToInternet)))

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == cached)
    #expect(model.failure == nil)
  }

  @Test func fetchesWhenTheCacheExpired() async throws {
    let cached = try await cacheForecast(for: osaka, age: 2 * 3600)
    let model = regionForecast(FakeWeatherProvider(.tokyo))

    await model.refreshIfNeeded(for: osaka)

    #expect(try #require(model.forecast).fetchedAt > cached.fetchedAt)
    #expect(model.failure == nil)
  }

  @Test func fetchesWhenNothingIsCached() async {
    let model = regionForecast(FakeWeatherProvider(.tokyo))

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast?.regionID == osaka.id)
    #expect(model.forecast?.placeName == "大阪市")
    #expect(!model.isLoading)
  }

  @Test func aFailedRefreshKeepsTheCachedForecast() async throws {
    let cached = try await cacheForecast(for: osaka, age: 2 * 3600)
    let model = regionForecast(FakeWeatherProvider(error: URLError(.notConnectedToInternet)))

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == cached)
    #expect(model.failure == .fetch)
  }

  @Test func aFailedFirstFetchLeavesNoForecast() async {
    let model = regionForecast(FakeWeatherProvider(error: URLError(.notConnectedToInternet)))

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == nil)
    #expect(model.failure == .fetch)
  }

  @Test func aSuccessClearsTheFailure() async {
    let weather = FakeWeatherProvider(error: URLError(.notConnectedToInternet))
    let model = regionForecast(weather)
    await model.refreshIfNeeded(for: osaka)
    await weather.set(.success(WeatherRecording.tokyo.forecast()))

    await model.refresh(for: osaka)

    #expect(model.failure == nil)
    #expect(model.forecast != nil)
  }

  @Test func theCurrentLocationIsNamedByReverseGeocoding() async {
    let model = regionForecast(FakeWeatherProvider(.tokyo), placeName: "大阪市北区")

    await model.refreshIfNeeded(for: .currentLocation)

    #expect(model.forecast?.placeName == "大阪市北区")
  }

  @Test func deniedLocationAccessIsReported() async {
    let model = regionForecast(FakeWeatherProvider(.tokyo), location: .denied)

    await model.refreshIfNeeded(for: .currentLocation)

    #expect(model.failure == .locationDenied)
  }

  @Test func aCancelledFetchIsNotAFailure() async {
    let model = regionForecast(FakeWeatherProvider(.tokyo, delay: .seconds(60)))

    let task = Task { await model.refreshIfNeeded(for: osaka) }
    try? await Task.sleep(for: .milliseconds(100))
    task.cancel()
    await task.value

    #expect(model.failure == nil)
    #expect(!model.isLoading)
  }

  @Test func anotherRegionShowsItsOwnCacheAndDropsTheOldOnes() async throws {
    let tokyo = SavedRegion.place(
      name: "港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751))
    _ = try await cacheForecast(for: tokyo, age: 60)
    let model = regionForecast(FakeWeatherProvider(.tokyo))
    await model.refreshIfNeeded(for: tokyo)
    // The widget may have cached the other region's forecast meanwhile.
    let osakaForecast = try await cacheForecast(for: osaka, age: 60)

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == osakaForecast)
    #expect(await cache.load(regionID: tokyo.id) == nil)
  }
}
