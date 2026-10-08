import Forecast
import Foundation
import Weather

/// The Apple Weather mark for the widgets. A widget can't load images while it is shown, so the
/// mark is downloaded once, while building a timeline, into the widget's caches directory.
struct AttributionMarkCache {
  private let file = URL.cachesDirectory.appending(path: "apple-weather-mark-dark.png")

  /// The mark for dark backgrounds (the widgets are orange or gray), or `nil` when it can't be
  /// downloaded now.
  func mark(using updater: ForecastUpdater) async -> Data? {
    if let data = try? Data(contentsOf: file) { return data }
    guard let attribution = try? await updater.attribution(),
      let (data, _) = try? await URLSession.shared.data(from: attribution.combinedMarkDarkURL)
    else { return nil }
    try? data.write(to: file, options: .atomic)
    return data
  }
}
