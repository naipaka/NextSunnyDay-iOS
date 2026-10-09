import CoreLocation
import Forecast
import Foundation
import LocationTesting
import PlaceSearchTesting
import Region
import SunnyDay
import Testing
import Units
import Weather
import WeatherTesting

@testable import NextSunnyDay

@MainActor
final class SunnyDayAnswerTests {
  private let defaults = UserDefaults(suiteName: "SunnyDayAnswerTests.\(UUID().uuidString)")!
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "SunnyDayAnswerTests-\(UUID().uuidString)", directoryHint: .isDirectory)
  private let minato = SavedRegion.place(name: "港区", coordinate: WeatherRecording.tokyo.coordinate)
  private let singapore = SavedRegion.place(
    name: "シンガポール", coordinate: WeatherRecording.singapore.coordinate)

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  private var cache: ForecastCache { ForecastCache(directory: directory) }

  /// The app's features on fakes, with `regions` saved: each region gets the weather recorded
  /// closest to it, unless `weather` says otherwise.
  private func features(
    _ regions: [SavedRegion], weather: any WeatherProviding = NearestRecordingWeatherProvider()
  ) -> AppFeatures {
    let regionStore = RegionStore(defaults: defaults)
    regionStore.save(regions)
    let places = FakePlaceSearch(nameAtCoordinate: "港区")
    return AppFeatures(
      regionStore: regionStore,
      regionSearch: RegionSearch(places: places),
      regionLocator: RegionLocator(location: FakeLocationProvider(), places: places),
      forecastUpdater: ForecastUpdater(weather: weather, cache: cache),
      sunnyLevelStore: SunnyLevelStore(defaults: defaults),
      temperatureUnitStore: TemperatureUnitStore(defaults: defaults))
  }

  @Test func answersForTheChosenRegion() async {
    let answer = await features([minato, singapore]).nextSunnyDayAnswer(regionID: singapore.id)

    #expect(answer == .noneInRange(placeName: "シンガポール"))
  }

  @Test func answersForTheFirstRegionWithoutOne() async throws {
    let answer = await features([minato, singapore]).nextSunnyDayAnswer(regionID: nil)

    guard case .sunny(let next, let placeName) = answer else {
      Issue.record("Expected a sunny day, got \(answer)")
      return
    }
    #expect(placeName == "港区")
    #expect(next.daysAway == 0)
  }

  @Test func answersForTheFirstRegionWhenTheChosenOneWasRemoved() async {
    let answer = await features([singapore, minato]).nextSunnyDayAnswer(regionID: "removed")

    #expect(answer == .noneInRange(placeName: "シンガポール"))
  }

  @Test func asksForARegionBeforeOneIsSaved() async {
    #expect(await features([]).nextSunnyDayAnswer(regionID: nil) == .noRegion)
  }

  @Test func namesTheCurrentLocationWhereItIs() async {
    let answer = await features([.currentLocation]).nextSunnyDayAnswer(regionID: nil)

    guard case .sunny(_, let placeName) = answer else {
      Issue.record("Expected a sunny day, got \(answer)")
      return
    }
    #expect(placeName == "港区")
  }

  @Test func answersFromTheCacheWhenTheFetchFails() async throws {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: .now)!
    let fetchedAt = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: yesterday)!
    try await cache.save(
      CachedForecast(
        regionID: singapore.id, placeName: "シンガポール",
        coordinate: WeatherRecording.singapore.coordinate,
        fetchedAt: fetchedAt, forecast: WeatherRecording.singapore.forecast()))

    let answer = await features(
      [singapore], weather: FakeWeatherProvider(error: URLError(.notConnectedToInternet))
    ).nextSunnyDayAnswer(regionID: nil)

    #expect(answer == .noneInRange(placeName: "シンガポール"))
  }

  @Test func saysTheWeatherIsMissingWhenNothingIsCachedAndTheFetchFails() async {
    let answer = await features(
      [minato], weather: FakeWeatherProvider(error: URLError(.notConnectedToInternet))
    ).nextSunnyDayAnswer(regionID: nil)

    #expect(answer == .noData)
  }

  @Test func countsSunnyDaysAtTheChosenLevel() {
    let cached = CachedForecast(
      regionID: minato.id, placeName: "港区", coordinate: WeatherRecording.tokyo.coordinate,
      fetchedAt: .now, forecast: WeatherRecording.tokyo.forecast())

    let looser = SunnyDayAnswer(region: minato, forecast: cached, level: .mostlyClear)
    let stricter = SunnyDayAnswer(region: minato, forecast: cached, level: .clear)

    guard case .sunny(let first, _) = looser, case .sunny(let clear, _) = stricter else {
      Issue.record("Expected sunny days, got \(looser) and \(stricter)")
      return
    }
    #expect(clear.daysAway > first.daysAway)
    #expect(clear.day.condition == .clear)
  }

  @Test func speaksInTheAppsWording() {
    var noRegion = SunnyDayAnswer.noRegion.dialog
    noRegion.locale = Locale(identifier: "ja")
    var none = SunnyDayAnswer.noneInRange(placeName: "シンガポール").dialog
    none.locale = Locale(identifier: "ja")

    #expect(String(localized: noRegion) == "アプリで地域を選んでね。")
    #expect(String(localized: none) == "シンガポールは 10日先まで晴れの予報がないよ。まだ先かも。")
  }
}
