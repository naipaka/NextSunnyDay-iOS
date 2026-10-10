import Foundation
import Notice
import Notifications
import NotificationsTesting
import Testing
import Weather

struct NoticeSchedulerTests {
  let date = Date(timeIntervalSince1970: 1_791_500_000)

  func notice(daysLater: Int) -> Notice {
    let day = DayForecast(
      date: Calendar.current.startOfDay(for: date.addingTimeInterval(Double(daysLater) * 86_400)),
      condition: .clear, symbolName: "sun.max", highTemperature: .init(value: 24, unit: .celsius),
      lowTemperature: .init(value: 16, unit: .celsius), precipitationChance: 0, sunrise: nil,
      sunset: nil, uvIndex: 0, windSpeed: .init(value: 0, unit: .kilometersPerHour),
      windDirection: .init(value: 0, unit: .degrees))
    return Notice(date: date.addingTimeInterval(Double(daysLater - 1) * 86_400), day: day)
  }

  func text(_ notice: Notice) -> NoticeText {
    NoticeText(title: "Minato", body: "Sunny tomorrow", hiddenPreviewsBody: "Tomorrow")
  }

  @Test func schedulesEachNoticeForTheRegion() async throws {
    let notifications = FakeNotificationScheduler(authorization: .authorized)
    let scheduler = NoticeScheduler(notifications: notifications)

    await scheduler.schedule([notice(daysLater: 1)], regionID: "minato", text: text)

    let scheduled = try #require(await notifications.pending().first)
    #expect(scheduled.date == notice(daysLater: 1).date)
    #expect(scheduled.title == "Minato")
    #expect(scheduled.body == "Sunny tomorrow")
    #expect(scheduled.hiddenPreviewsBody == "Tomorrow")
    #expect(NoticeScheduler.regionID(in: scheduled.userInfo) == "minato")
  }

  @Test func replacesTheNoticesScheduledBefore() async {
    let notifications = FakeNotificationScheduler(authorization: .authorized)
    let scheduler = NoticeScheduler(notifications: notifications)
    await scheduler.schedule(
      [notice(daysLater: 1), notice(daysLater: 2)], regionID: "minato", text: text)

    await scheduler.schedule([notice(daysLater: 2)], regionID: "minato", text: text)

    #expect(await notifications.pending().map(\.date) == [notice(daysLater: 2).date])
  }

  @Test func cancelsThemAll() async {
    let notifications = FakeNotificationScheduler(authorization: .authorized)
    let scheduler = NoticeScheduler(notifications: notifications)
    await scheduler.schedule([notice(daysLater: 1)], regionID: "minato", text: text)

    await scheduler.cancel()

    #expect(await notifications.pending().isEmpty)
  }

  @Test func asksForPermission() async {
    let scheduler = NoticeScheduler(notifications: FakeNotificationScheduler(answer: .denied))

    #expect(await scheduler.authorization() == .notDetermined)
    #expect(await scheduler.requestAuthorization() == .denied)
  }
}
