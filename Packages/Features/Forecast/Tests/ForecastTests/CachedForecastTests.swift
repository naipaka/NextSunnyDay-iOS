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

  @Test func isFreshForTheRestOfTheDayAfterFourEvenWhenExpired() {
    let forecast = cached(fetchedAt: date(8, 7), expiringAt: date(8, 8))

    #expect(forecast.isFresh(at: date(8, 23, 59), calendar: calendar))
    #expect(forecast.isExpired(at: date(8, 23, 59)))
  }

  @Test func staysFreshAcrossMidnightUntilFour() {
    let forecast = cached(fetchedAt: date(8, 7), expiringAt: date(8, 8))

    #expect(forecast.isFresh(at: date(9, 3, 59), calendar: calendar))
    #expect(!forecast.isFresh(at: date(9, 4), calendar: calendar))
  }

  @Test func aFetchBeforeFourIsStaleAtFour() {
    let forecast = cached(fetchedAt: date(9, 1), expiringAt: date(9, 2))

    #expect(forecast.isFresh(at: date(9, 3), calendar: calendar))
    #expect(!forecast.isFresh(at: date(9, 4, 30), calendar: calendar))
  }

  @Test func expiresAtTheWeatherServicesExpiration() {
    let forecast = cached(fetchedAt: date(8, 10), expiringAt: date(8, 11))

    #expect(!forecast.isExpired(at: date(8, 10, 59)))
    #expect(forecast.isExpired(at: date(8, 11)))
  }

  @Test func dailyFetchTimesAreAtFour() {
    #expect(
      CachedForecast.lastDailyFetchTime(atOrBefore: date(9, 3), calendar: calendar) == date(8, 4))
    #expect(
      CachedForecast.lastDailyFetchTime(atOrBefore: date(9, 4), calendar: calendar) == date(9, 4))
    #expect(CachedForecast.nextDailyFetchTime(after: date(9, 3), calendar: calendar) == date(9, 4))
    #expect(CachedForecast.nextDailyFetchTime(after: date(9, 4), calendar: calendar) == date(10, 4))
  }

  @Test func keepsItsCoordinate() {
    let forecast = cached(fetchedAt: date(8, 10), expiringAt: date(8, 11))

    #expect(forecast.coordinate.latitude == tokyo.latitude)
    #expect(forecast.coordinate.longitude == tokyo.longitude)
  }
}
