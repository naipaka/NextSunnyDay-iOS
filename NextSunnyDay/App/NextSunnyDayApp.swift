import SwiftUI

@main
struct NextSunnyDayApp: App {
  @State private var regionSelection: RegionSelection
  @State private var sunnyLevelSelection: SunnyLevelSelection
  @State private var temperatureUnitSelection: TemperatureUnitSelection
  @State private var regionForecast: RegionForecast
  private let features: AppFeatures

  init() {
    LegacyRealmCleanup.run()
    #if DEBUG
      let features = AppFeatures.launchScenario ?? .live
    #else
      let features = AppFeatures.live
    #endif
    self.features = features
    _regionSelection = State(
      initialValue: RegionSelection(store: features.regionStore, search: features.regionSearch))
    _sunnyLevelSelection = State(
      initialValue: SunnyLevelSelection(store: features.sunnyLevelStore))
    _temperatureUnitSelection = State(
      initialValue: TemperatureUnitSelection(store: features.temperatureUnitStore))
    _regionForecast = State(
      initialValue: RegionForecast(
        updater: features.forecastUpdater, locator: features.regionLocator))
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(regionSelection)
        .environment(sunnyLevelSelection)
        .environment(temperatureUnitSelection)
        .environment(regionForecast)
        .environment(\.regionSearch, features.regionSearch)
        .environment(\.forecastUpdater, features.forecastUpdater)
    }
  }
}

/// Onboarding until the user chooses a region, then Home.
struct RootView: View {
  @Environment(RegionSelection.self) private var regionSelection

  var body: some View {
    if let region = regionSelection.region {
      HomeView(region: region)
    } else {
      OnboardingView()
    }
  }
}
