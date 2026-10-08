import CoreLocation
import Forecast
import Foundation
import Testing
import WeatherTesting

struct CachedForecastTests {
  let tokyo = CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    return calendar
  }()

  private func cached(fetchedAt: Date, expiringAt expiration: Date) -> CachedForecast {
    CachedForecast(
      regionID: "r", placeName: nil, coordinate: tokyo, fetchedAt: fetchedAt,
      forecast: WeatherRecording.tokyo.forecast(
        startingOn: fetchedAt, expiringAt: expiration, calendar: calendar))
  }

  private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    calendar.date(
      from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
  }

  @Test func isFreshUntilItExpires() {
    let forecast = cached(fetchedAt: date(8, 10), expiringAt: date(8, 11))

    #expect(forecast.isFresh(at: date(8, 10, 59), calendar: calendar))
    #expect(!forecast.isFresh(at: date(8, 11), calendar: calendar))
  }

  @Test func isStaleOnTheNextDayEvenBeforeItExpires() {
    let forecast = cached(fetchedAt: date(8, 23, 30), expiringAt: date(9, 0, 30))

    #expect(!forecast.isFresh(at: date(9, 0, 10), calendar: calendar))
  }

  @Test func keepsItsCoordinate() {
    let forecast = cached(fetchedAt: date(8, 10), expiringAt: date(8, 11))

    #expect(forecast.coordinate.latitude == tokyo.latitude)
    #expect(forecast.coordinate.longitude == tokyo.longitude)
  }
}
