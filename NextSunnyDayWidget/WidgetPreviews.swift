import CoreLocation
import Forecast
import Foundation
import Region
import SunnyDay
import SwiftUI
import Weather
import WeatherTesting
import WidgetKit

/// The states every family handles, from the WeatherKit recordings.
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

#Preview("Small", as: .systemSmall) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Medium", as: .systemMedium) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Large", as: .systemLarge) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Inline", as: .accessoryInline) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Circular", as: .accessoryCircular) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Rectangular", as: .accessoryRectangular) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}
