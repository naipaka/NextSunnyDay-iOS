import CoreLocation
import Forecast
import Foundation
import Region
import SunnyDay
import Weather
import WeatherTesting

/// The states every family handles, from the WeatherKit recordings, for the previews of the
/// iPhone's widget and the watch's complications.
extension SunnyEntry {
  private static let minato = SavedRegion.place(
    name: "東京都港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751))

  private static func recorded(_ recording: WeatherRecording, fetchedAt: Date = .now)
    -> CachedForecast
  {
    CachedForecast(
      regionID: minato.id, placeName: nil,
      coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751),
      fetchedAt: fetchedAt, forecast: recording.forecast(startingOn: fetchedAt))
  }

  /// Tokyo's recording: a sunny day ahead.
  static var sunny: SunnyEntry {
    SunnyEntry(date: .now, region: minato, cached: recorded(.tokyo), level: .default)
  }

  /// Tokyo's recording at the laundry level: 「次の洗濯日和」.
  static var laundry: SunnyEntry {
    SunnyEntry(date: .now, region: minato, cached: recorded(.tokyo), level: .laundry)
  }

  /// Singapore's recording: no sunny day in ten days.
  static var noneInRange: SunnyEntry {
    SunnyEntry(date: .now, region: minato, cached: recorded(.singapore), level: .default)
  }

  /// Fetched eleven days ago, and every fetch since failed.
  static var noData: SunnyEntry {
    SunnyEntry(
      date: .now, region: minato, cached: recorded(.tokyo, fetchedAt: .now - 11 * 24 * 60 * 60),
      level: .default)
  }

  static var noRegion: SunnyEntry {
    SunnyEntry(date: .now, level: .default)
  }
}
