import AppGroup
import CoreLocation
import Forecast
import Foundation
import LocationTesting
import PlaceSearchTesting
import Region
import SunnyDay
import SwiftUI
import Units
import Weather
import WeatherTesting

/// The features the watch app uses, built in one place: the real ones, and ones on fakes of the
/// outside world for previews.
struct WatchFeatures {
  var regionStore: RegionStore
  var regionLocator: RegionLocator
  var forecastUpdater: ForecastUpdater
  var sunnyLevelStore: SunnyLevelStore
  var temperatureUnitStore: TemperatureUnitStore

  /// WeatherKit, Core Location, MapKit and the watch's App Group, where the iPhone's settings are
  /// copied to.
  static var live: WatchFeatures {
    WatchFeatures(
      regionStore: RegionStore(),
      regionLocator: RegionLocator(),
      forecastUpdater: ForecastUpdater(),
      sunnyLevelStore: SunnyLevelStore(),
      temperatureUnitStore: TemperatureUnitStore()
    )
  }

  /// The keys of the settings the iPhone copies to the watch: the regions (not the shown one,
  /// which each device keeps), the sunny level and the temperature unit.
  static let syncedKeys = [RegionStore.key, SunnyLevelStore.key, TemperatureUnitStore.key]
}

extension EnvironmentValues {
  /// What the weather data must credit, for the footer.
  @Entry var forecastUpdater = ForecastUpdater()
}

/// The situations the watch app's screen handles, on fakes of the outside world, for previews and
/// for `-PreviewScenario <name>` launches in a Debug build.
enum PreviewScenario: String {
  /// Tokyo's recording: a sunny day ahead.
  case tokyo
  /// Tokyo's recording at the laundry level.
  case laundry
  /// Singapore's recording: no sunny day in ten days.
  case singapore
  /// Los Angeles' recording, for the English screenshots. Launch in Los Angeles' time zone.
  case losAngeles
  /// The first fetch is still running.
  case loading
  /// A cached forecast is shown, but the refresh failed.
  case refreshFailed
  /// The fetch failed and nothing is cached.
  case offline
  /// The current location is chosen, but location access is off.
  case locationDenied
  /// The iPhone hasn't sent any region yet.
  case noRegion
  /// Three regions, Minato shown: the current location (also in Minato) and Singapore.
  case severalRegions
}

extension WatchFeatures {
  static func preview(_ scenario: PreviewScenario) -> WatchFeatures {
    let defaults = UserDefaults(suiteName: "preview-\(UUID().uuidString)")!
    let cacheDirectory = FileManager.default.temporaryDirectory
      .appending(path: "preview-\(UUID().uuidString)", directoryHint: .isDirectory)
    let minato = CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)
    // Names as MapKit gives them in the app's language.
    let isJapanese = Bundle.main.preferredLocalizations.first == "ja"
    let minatoName = isJapanese ? "港区" : "Minato"
    let place = SavedRegion.place(name: minatoName, coordinate: minato)

    let weather: any WeatherProviding
    var regions: [SavedRegion] = [place]
    var location = FakeLocationProvider()
    switch scenario {
    case .tokyo, .laundry, .noRegion:
      weather = FakeWeatherProvider(.tokyo)
      if scenario == .noRegion { regions = [] }
    case .singapore:
      weather = FakeWeatherProvider(.singapore)
    case .losAngeles:
      weather = FakeWeatherProvider(.losAngeles)
      regions = [
        .place(
          name: isJapanese ? "ロサンゼルス" : "Los Angeles",
          coordinate: WeatherRecording.losAngeles.coordinate)
      ]
    case .loading:
      weather = FakeWeatherProvider(.tokyo, delay: .seconds(3600))
    case .refreshFailed, .offline:
      weather = FakeWeatherProvider(error: URLError(.notConnectedToInternet))
    case .severalRegions:
      weather = NearestRecordingWeatherProvider()
      regions = [
        place, .currentLocation,
        .place(
          name: isJapanese ? "シンガポール" : "Singapore",
          coordinate: WeatherRecording.singapore.coordinate),
      ]
    case .locationDenied:
      weather = FakeWeatherProvider(.tokyo)
      regions = [.currentLocation]
      location = .denied
    }

    let cache = ForecastCache(directory: cacheDirectory)
    if scenario == .refreshFailed {
      // Fetched at 3:00 yesterday, before the last 4:00 at any time of day, so the app fetches
      // again (ADR 0006).
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
      let fetchedAt = Calendar.current.date(
        bySettingHour: 3, minute: 0, second: 0, of: yesterday)!
      let stale = CachedForecast(
        regionID: place.id, placeName: minatoName, coordinate: minato, fetchedAt: fetchedAt,
        forecast: WeatherRecording.tokyo.forecast(expiringAt: fetchedAt.addingTimeInterval(3600)))
      let saved = DispatchSemaphore(value: 0)
      Task.detached {
        try? await cache.save(stale)
        saved.signal()
      }
      saved.wait()
    }

    RegionStore(defaults: defaults).save(regions)
    let sunnyLevelStore = SunnyLevelStore(defaults: defaults)
    if scenario == .laundry {
      sunnyLevelStore.save(.laundry)
    }
    let places = FakePlaceSearch()
    return WatchFeatures(
      regionStore: RegionStore(defaults: defaults),
      regionLocator: RegionLocator(location: location, places: places),
      forecastUpdater: ForecastUpdater(weather: weather, cache: cache),
      sunnyLevelStore: sunnyLevelStore,
      temperatureUnitStore: TemperatureUnitStore(defaults: defaults)
    )
  }
}

#if DEBUG
  extension WatchFeatures {
    /// The features of a preview scenario when the app is launched with
    /// `-PreviewScenario <name>`, to look at a state in the simulator.
    static var launchScenario: WatchFeatures? {
      UserDefaults.standard.string(forKey: "PreviewScenario")
        .flatMap(PreviewScenario.init(rawValue:))
        .map(preview)
    }
  }
#endif
