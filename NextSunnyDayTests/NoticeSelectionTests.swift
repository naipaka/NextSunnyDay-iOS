import Forecast
import Foundation
import LocationTesting
import Notice
import Notifications
import NotificationsTesting
import PlaceSearchTesting
import Region
import SunnyDay
import Testing
import Units
import Weather
import WeatherTesting

@testable import NextSunnyDay

@MainActor
final class NoticeSelectionTests {
  private let defaults = UserDefaults(suiteName: "NoticeSelectionTests.\(UUID().uuidString)")!
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "NoticeSelectionTests-\(UUID().uuidString)", directoryHint: .isDirectory)
  private let minato = SavedRegion.place(name: "港区", coordinate: WeatherRecording.tokyo.coordinate)
  private let singapore = SavedRegion.place(
    name: "シンガポール", coordinate: WeatherRecording.singapore.coordinate)
  /// 10:00 today: Tokyo's recording starts mostly clear, then clear.
  private let now = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: .now)!

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  /// The app's features on fakes, with `regions` saved and each one's recording cached as if
  /// fetched `now`, at the "clear only" level so that tomorrow is the first sunny day in Tokyo.
  private func features(
    _ regions: [SavedRegion], notifications: FakeNotificationScheduler
  ) async throws -> AppFeatures {
    let regionStore = RegionStore(defaults: defaults)
    regionStore.save(regions)
    let cache = ForecastCache(directory: directory)
    for region in regions {
      let recording: WeatherRecording = region.id == singapore.id ? .singapore : .tokyo
      try await cache.save(
        CachedForecast(
          regionID: region.id, placeName: region.placeName, coordinate: recording.coordinate,
          fetchedAt: now, forecast: recording.forecast(startingOn: now)))
    }
    let sunnyLevelStore = SunnyLevelStore(defaults: defaults)
    sunnyLevelStore.save(.clear)
    let places = FakePlaceSearch()
    return AppFeatures(
      regionStore: regionStore,
      regionSearch: RegionSearch(places: places),
      regionLocator: RegionLocator(location: FakeLocationProvider(), places: places),
      forecastUpdater: ForecastUpdater(
        weather: NearestRecordingWeatherProvider(), cache: cache),
      sunnyLevelStore: sunnyLevelStore,
      temperatureUnitStore: TemperatureUnitStore(defaults: defaults),
      noticeStore: NoticeSettingStore(defaults: defaults),
      noticeScheduler: NoticeScheduler(notifications: notifications))
  }

  @Test func offUntilTurnedOn() async throws {
    let selection = NoticeSelection(
      features: try await features([minato], notifications: FakeNotificationScheduler()))

    #expect(!selection.isOn)
    #expect(selection.setting.time == NoticeTime(hour: 19, minute: 0))
  }

  @Test func turningOnAsksForPermission() async throws {
    let features = try await features([minato], notifications: FakeNotificationScheduler())
    let selection = NoticeSelection(features: features)

    await selection.turnOn()

    #expect(selection.isOn)
    #expect(selection.authorization == .authorized)
    #expect(features.noticeStore.load().isOn)
  }

  @Test func staysOffWhenNotAllowed() async throws {
    let features = try await features(
      [minato], notifications: FakeNotificationScheduler(answer: .denied))
    let selection = NoticeSelection(features: features)

    await selection.turnOn()

    #expect(!selection.isOn)
    #expect(selection.authorization == .denied)
    #expect(!features.noticeStore.load().isOn)
  }

  @Test func showsOffWhenTurnedOffInTheSystemSettings() async throws {
    let features = try await features(
      [minato], notifications: FakeNotificationScheduler(authorization: .denied))
    features.noticeStore.save(NoticeSetting(isOn: true, regionID: nil, time: .default))
    let selection = NoticeSelection(features: features)

    await selection.refreshAuthorization()

    #expect(!selection.isOn)
  }

  @Test func schedulesTheEveningBeforeTheFirstRegionsSunnyDay() async throws {
    let notifications = FakeNotificationScheduler()
    let selection = NoticeSelection(
      features: try await features([minato, singapore], notifications: notifications))
    await selection.turnOn()

    await selection.reschedule(now: now)

    let scheduled = try #require(await notifications.pending().first)
    #expect(await notifications.pending().count == 1)
    #expect(scheduled.date == Calendar.current.date(byAdding: .hour, value: 9, to: now))
    #expect(scheduled.title == "港区")
    #expect(NoticeScheduler.regionID(in: scheduled.userInfo) == minato.id)
  }

  @Test func schedulesForTheChosenRegion() async throws {
    let notifications = FakeNotificationScheduler()
    let selection = NoticeSelection(
      features: try await features([minato, singapore], notifications: notifications))
    await selection.turnOn()

    // Singapore has no sunny day.
    selection.selectRegion(id: singapore.id)
    await selection.reschedule(now: now)

    #expect(await notifications.pending().isEmpty)
  }

  @Test func fallsBackToTheFirstRegionWhenTheChosenOneIsRemoved() async throws {
    let notifications = FakeNotificationScheduler()
    let selection = NoticeSelection(
      features: try await features([minato], notifications: notifications))
    await selection.turnOn()

    selection.selectRegion(id: "removed")
    await selection.reschedule(now: now)

    #expect(await notifications.pending().first?.title == "港区")
  }

  @Test func atTheChosenTime() async throws {
    let notifications = FakeNotificationScheduler()
    let selection = NoticeSelection(
      features: try await features([minato], notifications: notifications))
    await selection.turnOn()

    selection.selectTime(NoticeTime(hour: 21, minute: 30))
    await selection.reschedule(now: now)

    let scheduled = try #require(await notifications.pending().first)
    #expect(Calendar.current.dateComponents([.hour, .minute], from: scheduled.date).hour == 21)
    #expect(Calendar.current.dateComponents([.hour, .minute], from: scheduled.date).minute == 30)
  }

  @Test func turningOffCancelsThem() async throws {
    let notifications = FakeNotificationScheduler()
    let selection = NoticeSelection(
      features: try await features([minato], notifications: notifications))
    await selection.turnOn()
    await selection.reschedule(now: now)

    selection.turnOff()
    await selection.reschedule(now: now)

    #expect(await notifications.pending().isEmpty)
  }

  @Test func followsTheSunnyLevel() async throws {
    let notifications = FakeNotificationScheduler()
    let features = try await features([minato], notifications: notifications)
    let selection = NoticeSelection(features: features)
    await selection.turnOn()

    // At the default level Tokyo is sunny today and tomorrow: nothing to announce.
    features.sunnyLevelStore.save(.mostlyClear)
    await selection.reschedule(now: now)

    #expect(await notifications.pending().isEmpty)
  }
}
