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

  /// `hour` o'clock today, or `days` later.
  private func date(_ hour: Int, days: Int = 0) -> Date {
    let calendar = Calendar.current
    let day = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: .now))!
    return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day)!
  }

  private func regionForecast(
    _ weather: FakeWeatherProvider, location: FakeLocationProvider = FakeLocationProvider(),
    placeName: String? = "東京都港区", now: Date? = nil
  ) -> RegionForecast {
    let now = now ?? date(12)
    return RegionForecast(
      updater: ForecastUpdater(weather: weather, cache: cache, now: { now }),
      locator: RegionLocator(
        location: location, places: FakePlaceSearch(nameAtCoordinate: placeName)))
  }

  /// A forecast cached for `region`, fetched at `fetchedAt` (11:00 today by default) and
  /// expiring an hour after that.
  private func cacheForecast(for region: SavedRegion, fetchedAt: Date? = nil) async throws
    -> CachedForecast
  {
    let fetchedAt = fetchedAt ?? date(11)
    let cached = CachedForecast(
      regionID: region.id, placeName: region.placeName,
      coordinate: CLLocationCoordinate2D(latitude: 34.702, longitude: 135.496),
      fetchedAt: fetchedAt,
      forecast: WeatherRecording.tokyo.forecast(expiringAt: fetchedAt.addingTimeInterval(3600)))
    try await cache.save(cached)
    return cached
  }

  @Test func showsTodaysCacheWithoutFetchingEvenWhenExpired() async throws {
    let cached = try await cacheForecast(for: osaka, fetchedAt: date(5))
    let model = regionForecast(FakeWeatherProvider(error: URLError(.notConnectedToInternet)))

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == cached)
    #expect(model.failure == nil)
  }

  @Test func doesntFetchAfterMidnightBeforeFour() async throws {
    let cached = try await cacheForecast(for: osaka, fetchedAt: date(20))
    let model = regionForecast(
      FakeWeatherProvider(error: URLError(.notConnectedToInternet)), now: date(2, days: 1))

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == cached)
    #expect(model.failure == nil)
  }

  @Test func fetchesWhenTheCacheIsFromBeforeFour() async throws {
    let cached = try await cacheForecast(for: osaka, fetchedAt: date(3))
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
    let cached = try await cacheForecast(for: osaka, fetchedAt: date(3))
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

  @Test func pullingWithinTheExpirationDoesntFetch() async throws {
    let cached = try await cacheForecast(for: osaka)
    let model = regionForecast(FakeWeatherProvider(.tokyo), now: date(11).addingTimeInterval(1800))
    await model.refreshIfNeeded(for: osaka)

    await model.refresh(for: osaka)

    #expect(model.forecast == cached)
  }

  @Test func pullingAfterTheExpirationFetches() async throws {
    let cached = try await cacheForecast(for: osaka)
    let model = regionForecast(FakeWeatherProvider(.tokyo))
    await model.refreshIfNeeded(for: osaka)

    await model.refresh(for: osaka)

    #expect(try #require(model.forecast).fetchedAt > cached.fetchedAt)
  }

  @Test func retryingAfterAFailureFetches() async throws {
    let cached = try await cacheForecast(for: osaka, fetchedAt: date(3))
    let weather = FakeWeatherProvider(error: URLError(.notConnectedToInternet))
    let model = regionForecast(weather, now: date(3).addingTimeInterval(4 * 3600 + 1800))
    await model.refreshIfNeeded(for: osaka)
    #expect(model.failure == .fetch)
    await weather.set(.success(WeatherRecording.tokyo.forecast(expiringAt: date(10))))

    await model.refresh(for: osaka)

    #expect(model.failure == nil)
    #expect(try #require(model.forecast).fetchedAt > cached.fetchedAt)
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
    _ = try await cacheForecast(for: tokyo)
    let model = regionForecast(FakeWeatherProvider(.tokyo))
    await model.refreshIfNeeded(for: tokyo)
    // The widget may have cached the other region's forecast meanwhile.
    let osakaForecast = try await cacheForecast(for: osaka)

    await model.refreshIfNeeded(for: osaka)

    #expect(model.forecast == osakaForecast)
    #expect(await cache.load(regionID: tokyo.id) == nil)
  }
}
