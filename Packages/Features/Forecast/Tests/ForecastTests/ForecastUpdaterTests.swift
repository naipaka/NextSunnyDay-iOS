import CoreLocation
import Forecast
import Foundation
import Testing
import Weather
import WeatherTesting

final class ForecastUpdaterTests {
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "ForecastUpdaterTests-\(UUID().uuidString)", directoryHint: .isDirectory)
  private let osaka = CLLocationCoordinate2D(latitude: 34.702, longitude: 135.496)
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  private func updater(_ weather: FakeWeatherProvider) -> ForecastUpdater {
    let now = now
    return ForecastUpdater(
      weather: weather, cache: ForecastCache(directory: directory), now: { now })
  }

  @Test func fetchCachesTheForecastForTheRegion() async throws {
    let updater = updater(FakeWeatherProvider(.tokyo))

    let fetched = try await updater.fetch(regionID: "r", placeName: "大阪駅", coordinate: osaka)

    #expect(fetched.fetchedAt == now)
    #expect(fetched.placeName == "大阪駅")
    #expect(fetched.coordinate.latitude == osaka.latitude)
    #expect(await updater.cached(regionID: "r") == fetched)
  }

  @Test func aFailedFetchKeepsTheCachedForecast() async throws {
    let weather = FakeWeatherProvider(.tokyo)
    let updater = updater(weather)
    let fetched = try await updater.fetch(regionID: "r", placeName: nil, coordinate: osaka)
    await weather.set(.failure(URLError(.notConnectedToInternet)))

    await #expect(throws: URLError.self) {
      try await updater.fetch(regionID: "r", placeName: nil, coordinate: osaka)
    }
    #expect(await updater.cached(regionID: "r") == fetched)
  }

  @Test func freshnessAndExpirationUseTheClock() async throws {
    let expiring = WeatherRecording.tokyo.forecast(
      startingOn: now, expiringAt: now.addingTimeInterval(60 * 60))
    let updater = updater(FakeWeatherProvider(forecast: expiring))

    let fetched = try await updater.fetch(regionID: "r", placeName: nil, coordinate: osaka)

    #expect(updater.isFresh(fetched))
    #expect(!updater.isExpired(fetched))
    #expect(fetched.isExpired(at: now.addingTimeInterval(60 * 60)))
    #expect(updater.nextDailyFetchTime() == CachedForecast.nextDailyFetchTime(after: now))
  }

  @Test func removedRegionsLoseTheirForecasts() async throws {
    let updater = updater(FakeWeatherProvider(.tokyo))
    _ = try await updater.fetch(regionID: "kept", placeName: nil, coordinate: osaka)
    _ = try await updater.fetch(regionID: "removed", placeName: nil, coordinate: osaka)

    await updater.removeForecasts(except: ["kept"])

    #expect(await updater.cached(regionID: "kept") != nil)
    #expect(await updater.cached(regionID: "removed") == nil)
  }
}
