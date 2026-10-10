import AppIntents
import Forecast
import Notice
import Notifications
import Region
import SunnyDay
import SwiftUI

@main
struct NextSunnyDayApp: App {
  @State private var regionSelection: RegionSelection
  @State private var sunnyLevelSelection: SunnyLevelSelection
  @State private var temperatureUnitSelection: TemperatureUnitSelection
  @State private var regionForecast: RegionForecast
  @State private var noticeSelection: NoticeSelection
  private let features: AppFeatures
  private let notificationResponder = NotificationResponder()

  init() {
    LegacyRealmCleanup.run()
    #if DEBUG
      let features = AppFeatures.launchScenario ?? .live
    #else
      let features = AppFeatures.live
    #endif
    self.features = features
    // Siri and Shortcuts run `NextSunnyDayIntent` in this process, on the same features.
    AppDependencyManager.shared.add(dependency: features)
    let regionSelection = RegionSelection(
      store: features.regionStore, search: features.regionSearch,
      forecastUpdater: features.forecastUpdater)
    _regionSelection = State(initialValue: regionSelection)
    _sunnyLevelSelection = State(
      initialValue: SunnyLevelSelection(store: features.sunnyLevelStore))
    _temperatureUnitSelection = State(
      initialValue: TemperatureUnitSelection(store: features.temperatureUnitStore))
    let regionForecast = RegionForecast(
      updater: features.forecastUpdater, locator: features.regionLocator)
    _regionForecast = State(initialValue: regionForecast)
    let noticeSelection = NoticeSelection(features: features)
    _noticeSelection = State(initialValue: noticeSelection)

    // Opening a notification shows its region; the system's notification settings open the app's.
    notificationResponder.onOpen = { userInfo in
      if let region = regionSelection.regions.first(where: {
        $0.id == NoticeScheduler.regionID(in: userInfo)
      }) {
        regionSelection.select(region)
      }
    }
    notificationResponder.onOpenSettings = { noticeSelection.isSettingsRequested = true }
    notificationResponder.activate()
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(regionSelection)
        .environment(sunnyLevelSelection)
        .environment(temperatureUnitSelection)
        .environment(regionForecast)
        .environment(noticeSelection)
        .environment(\.regionSearch, features.regionSearch)
        .environment(\.forecastUpdater, features.forecastUpdater)
    }
  }
}

/// Onboarding until the user chooses a region, then Home. Keeps the notifications in step with
/// the forecast and the settings.
struct RootView: View {
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(RegionForecast.self) private var regionForecast
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection
  @Environment(NoticeSelection.self) private var noticeSelection
  @Environment(\.scenePhase) private var scenePhase

  /// What the notifications depend on. Becoming active covers a fetch by the widget or Siri and a
  /// permission changed in the system's settings.
  private struct NoticeKey: Equatable {
    var setting: NoticeSetting
    var regions: RegionList
    var level: SunnyLevel
    var unit: UnitTemperature
    var fetchedAt: Date?
    var isActive: Bool
  }

  var body: some View {
    Group {
      if let region = regionSelection.region {
        HomeView(region: region)
      } else {
        OnboardingView()
      }
    }
    .task(id: noticeKey) {
      guard scenePhase == .active else { return }
      await noticeSelection.refreshAuthorization()
      await noticeSelection.reschedule()
    }
  }

  private var noticeKey: NoticeKey {
    NoticeKey(
      setting: noticeSelection.setting, regions: regionSelection.list,
      level: sunnyLevelSelection.level, unit: temperatureUnitSelection.unit,
      fetchedAt: regionForecast.forecast?.fetchedAt, isActive: scenePhase == .active)
  }
}
