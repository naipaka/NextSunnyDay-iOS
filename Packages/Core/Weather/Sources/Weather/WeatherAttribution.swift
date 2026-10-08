import Foundation

/// What the app must show for the weather data: the Apple Weather mark and the legal page.
public struct WeatherDataAttribution: Equatable, Sendable {
  public var serviceName: String
  public var legalPageURL: URL
  /// The mark for light backgrounds.
  public var combinedMarkLightURL: URL
  /// The mark for dark backgrounds.
  public var combinedMarkDarkURL: URL

  public init(
    serviceName: String, legalPageURL: URL, combinedMarkLightURL: URL, combinedMarkDarkURL: URL
  ) {
    self.serviceName = serviceName
    self.legalPageURL = legalPageURL
    self.combinedMarkLightURL = combinedMarkLightURL
    self.combinedMarkDarkURL = combinedMarkDarkURL
  }
}
