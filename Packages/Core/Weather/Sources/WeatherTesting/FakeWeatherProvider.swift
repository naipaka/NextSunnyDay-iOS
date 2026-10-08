import CoreLocation
import Foundation
import Weather

/// A `WeatherProviding` that answers without the network: with a recording by default, or with
/// the forecast or error it is set to.
public actor FakeWeatherProvider: WeatherProviding {
  private var result: Result<WeatherForecast, any Error>
  /// How long each fetch takes, to show loading states.
  private var delay: Duration = .zero

  /// - Parameter delay: How long each fetch takes, to show loading states.
  public init(_ recording: WeatherRecording = .tokyo, delay: Duration = .zero) {
    result = .success(recording.forecast())
    self.delay = delay
  }

  public init(forecast: WeatherForecast) {
    result = .success(forecast)
  }

  public init(error: any Error) {
    result = .failure(error)
  }

  /// Changes what the next fetches return.
  public func set(_ result: Result<WeatherForecast, any Error>) {
    self.result = result
  }

  /// Makes each fetch take `delay`.
  public func set(delay: Duration) {
    self.delay = delay
  }

  public func forecast(for coordinate: CLLocationCoordinate2D) async throws -> WeatherForecast {
    try await Task.sleep(for: delay)
    return try result.get()
  }

  public func attribution() async throws -> WeatherDataAttribution {
    .sample
  }
}

extension WeatherDataAttribution {
  /// Apple Weather's attribution as WeatherKit returns it, with the marks in Japanese when the app
  /// runs in Japanese and in English otherwise.
  public static var sample: WeatherDataAttribution {
    let language = Bundle.main.preferredLocalizations.first == "ja" ? "ja" : "en"
    let branding = "https://weatherkit.apple.com/assets/branding/\(language)/Apple_Weather"
    return WeatherDataAttribution(
      serviceName: "Apple Weather",
      legalPageURL: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!,
      combinedMarkLightURL: URL(string: "\(branding)_blk_\(language)_3X_090122.png")!,
      combinedMarkDarkURL: URL(string: "\(branding)_wht_\(language)_3X_090122.png")!
    )
  }
}
