import Foundation
import Testing
import Weather
import WeatherTesting

struct WeatherForecastTests {
  @Test func recordedForecastConvertsEveryDayAndHour() {
    let forecast = WeatherRecording.tokyo.recorded

    #expect(forecast.daily.count == 10)
    #expect(forecast.hourly.count == 240)
    #expect(forecast.daily.prefix(2).map(\.condition) == [.mostlyClear, .clear])
    #expect(forecast.daily.allSatisfy { $0.lowTemperature <= $0.highTemperature })
    #expect(forecast.daily.allSatisfy { (0...1).contains($0.precipitationChance) })
  }

  @Test(arguments: WeatherRecording.allCases)
  func everyRecordingHasTenDaysAndTheirHours(_ recording: WeatherRecording) {
    let forecast = recording.recorded

    #expect(forecast.daily.count == 10)
    #expect(forecast.hourly.count == 240)
  }

  @Test func expirationIsTheEarlierOfTheDailyAndHourlyData() {
    let forecast = WeatherRecording.tokyo.recorded

    // Both expired one hour after they were fetched.
    #expect(forecast.expirationDate == ISO8601DateFormatter().date(from: "2026-10-07T20:32:55Z"))
  }

  @Test func daysFromTodaySkipTheDaysBefore() throws {
    let forecast = WeatherRecording.tokyo.forecast()
    let tomorrow = try #require(Calendar.current.date(byAdding: .day, value: 1, to: .now))

    #expect(forecast.days(from: .now) == forecast.daily)
    #expect(forecast.days(from: tomorrow) == Array(forecast.daily.dropFirst()))
  }

  @Test func everyWeatherKitConditionHasItsOwnCase() {
    for rawValue in WeatherCondition.weatherKitRawValues {
      #expect(WeatherCondition(rawValue: rawValue) != nil, "\(rawValue)")
    }
  }

  @Test func conditionsHaveLocalizedNames() {
    let named = WeatherCondition.allCases.filter { $0 != .unknown }
    #expect(named.allSatisfy { !$0.localizedName.isEmpty })
  }

  @Test func forecastSurvivesEncoding() throws {
    let forecast = WeatherRecording.singapore.recorded
    let decoded = try JSONDecoder().decode(
      WeatherForecast.self, from: try JSONEncoder().encode(forecast))

    #expect(decoded == forecast)
  }

  @Test func recordingCanStartOnAnyDay() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    let day = calendar.date(from: DateComponents(year: 2027, month: 1, day: 15, hour: 9))!
    let recorded = WeatherRecording.tokyo.recorded

    let moved = WeatherRecording.tokyo.forecast(startingOn: day, calendar: calendar)

    #expect(moved.daily.first?.date == calendar.startOfDay(for: day))
    let offset = moved.daily[0].date.timeIntervalSince(recorded.daily[0].date)
    #expect(moved.hourly[5].date == recorded.hourly[5].date + offset)
    #expect(moved.daily[3].sunrise == recorded.daily[3].sunrise.map { $0 + offset })
  }
}
