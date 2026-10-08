import CoreLocation
import Forecast
import Foundation
import LocationTesting
import PlaceSearchTesting
import Region
import SunnyDay
import SwiftUI
import Weather
import WeatherTesting

/// Shows a view with the real state holders and features on fakes of the outside world, in one
/// of the situations the screens handle.
struct PreviewHost<Content: View>: View {
  enum Scenario: String {
    /// Tokyo's recording: a sunny day ahead.
    case tokyo
    /// Singapore's recording: no sunny day in ten days.
    case singapore
    /// The first fetch is still running.
    case loading
    /// A cached forecast is shown, but the refresh failed.
    case refreshFailed
    /// The fetch failed and nothing is cached.
    case offline
    /// The current location is chosen, but location access is off.
    case locationDenied
    /// No region yet.
    case noRegion
  }

  @State private var regionSelection: RegionSelection
  @State private var sunnyLevelSelection: SunnyLevelSelection
  @State private var regionForecast: RegionForecast
  private let features: AppFeatures
  private let content: Content

  init(_ scenario: Scenario, @ViewBuilder content: () -> Content) {
    let features = AppFeatures.preview(scenario)
    self.features = features
    self.content = content()
    _regionSelection = State(
      initialValue: RegionSelection(store: features.regionStore, search: features.regionSearch))
    _sunnyLevelSelection = State(
      initialValue: SunnyLevelSelection(store: features.sunnyLevelStore))
    _regionForecast = State(
      initialValue: RegionForecast(
        updater: features.forecastUpdater, locator: features.regionLocator))
  }

  var body: some View {
    content
      .environment(regionSelection)
      .environment(sunnyLevelSelection)
      .environment(regionForecast)
      .environment(\.regionSearch, features.regionSearch)
      .environment(\.forecastUpdater, features.forecastUpdater)
  }
}

extension PreviewHost where Content == RootView {
  init(_ scenario: Scenario) {
    self.init(scenario) { RootView() }
  }
}

extension AppFeatures {
  static func preview<Content>(_ scenario: PreviewHost<Content>.Scenario) -> AppFeatures {
    let defaults = UserDefaults(suiteName: "preview-\(UUID().uuidString)")!
    let cacheDirectory = FileManager.default.temporaryDirectory
      .appending(path: "preview-\(UUID().uuidString)", directoryHint: .isDirectory)
    let minato = CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)
    let place = SavedRegion.place(name: "港区", coordinate: minato)

    let weather: FakeWeatherProvider
    var region: SavedRegion? = place
    var location = FakeLocationProvider()
    switch scenario {
    case .tokyo, .noRegion:
      weather = FakeWeatherProvider(.tokyo)
      if scenario == .noRegion { region = nil }
    case .singapore:
      weather = FakeWeatherProvider(.singapore)
    case .loading:
      weather = FakeWeatherProvider(.tokyo, delay: .seconds(3600))
    case .refreshFailed, .offline:
      weather = FakeWeatherProvider(error: URLError(.notConnectedToInternet))
    case .locationDenied:
      weather = FakeWeatherProvider(.tokyo)
      region = .currentLocation
      location = .denied
    }

    let cache = ForecastCache(directory: cacheDirectory)
    if scenario == .refreshFailed {
      // Fetched at 3:00 yesterday, before the last 4:00 at any time of day, so Home fetches
      // again (ADR 0006).
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
      let fetchedAt = Calendar.current.date(
        bySettingHour: 3, minute: 0, second: 0, of: yesterday)!
      let stale = CachedForecast(
        regionID: place.id, placeName: "港区", coordinate: minato, fetchedAt: fetchedAt,
        forecast: WeatherRecording.tokyo.forecast(expiringAt: fetchedAt.addingTimeInterval(3600)))
      // Written before the screens start, as an earlier launch would have left it.
      let saved = DispatchSemaphore(value: 0)
      Task.detached {
        try? await cache.save(stale)
        saved.signal()
      }
      saved.wait()
    }

    let regionStore = RegionStore(defaults: defaults)
    regionStore.save(region.map { [$0] } ?? [])
    let places = FakePlaceSearch()
    return AppFeatures(
      regionStore: regionStore,
      regionSearch: RegionSearch(places: places),
      regionLocator: RegionLocator(location: location, places: places),
      forecastUpdater: ForecastUpdater(weather: weather, cache: cache),
      sunnyLevelStore: SunnyLevelStore(defaults: defaults)
    )
  }
}

#if DEBUG
  extension AppFeatures {
    /// The features of a preview scenario when the app is launched with
    /// `-PreviewScenario <name>`, to look at a state in the simulator.
    static var launchScenario: AppFeatures? {
      UserDefaults.standard.string(forKey: "PreviewScenario")
        .flatMap(PreviewHost<EmptyView>.Scenario.init(rawValue:))
        .map(preview)
    }
  }
#endif
