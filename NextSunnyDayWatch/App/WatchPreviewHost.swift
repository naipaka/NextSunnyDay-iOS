import SwiftUI

/// Shows a view with the real state holders and features on fakes of the outside world, in one
/// of the situations the screen handles.
struct WatchPreviewHost<Content: View>: View {
  @State private var settings: SyncedSettings
  @State private var forecast: WatchForecast
  private let features: WatchFeatures
  private let content: Content

  init(_ scenario: PreviewScenario, @ViewBuilder content: () -> Content) {
    let features = WatchFeatures.preview(scenario)
    self.features = features
    self.content = content()
    _settings = State(initialValue: SyncedSettings(features: features))
    _forecast = State(
      initialValue: WatchForecast(
        updater: features.forecastUpdater, locator: features.regionLocator))
  }

  var body: some View {
    content
      .environment(settings)
      .environment(forecast)
      .environment(\.forecastUpdater, features.forecastUpdater)
  }
}

extension WatchPreviewHost where Content == SunnyDayView {
  init(_ scenario: PreviewScenario) {
    self.init(scenario) { SunnyDayView() }
  }
}
