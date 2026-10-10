import AppGroup
import Forecast
import Region
import SwiftUI
import WatchSync
import WidgetKit

@main
struct NextSunnyDayWatchApp: App {
  @State private var settings: SyncedSettings
  @State private var forecast: WatchForecast
  private let features: WatchFeatures
  private let settingsSync: SettingsSync

  init() {
    #if DEBUG
      let features = WatchFeatures.launchScenario ?? .live
    #else
      let features = WatchFeatures.live
    #endif
    self.features = features
    let settings = SyncedSettings(features: features)
    _settings = State(initialValue: settings)
    _forecast = State(
      initialValue: WatchForecast(
        updater: features.forecastUpdater, locator: features.regionLocator))

    // The iPhone's regions, sunny level and unit arrive here, also while the app isn't open.
    let updater = features.forecastUpdater
    settingsSync = SettingsSync(
      mirror: SettingsMirror(
        keys: WatchFeatures.syncedKeys, defaults: AppGroupContainer.userDefaults)
    ) {
      Task { @MainActor in
        settings.reload()
        WidgetCenter.shared.reloadAllTimelines()
        WidgetCenter.shared.invalidateConfigurationRecommendations()
        await updater.removeForecasts(except: Set(settings.regions.map(\.id)))
      }
    }
    settingsSync.activate()
  }

  var body: some Scene {
    WindowGroup {
      SunnyDayView()
        .environment(settings)
        .environment(forecast)
        .environment(\.forecastUpdater, features.forecastUpdater)
    }
    .backgroundTask(.watchConnectivity) {
      await settingsSync.waitForPendingContent()
    }
  }
}
