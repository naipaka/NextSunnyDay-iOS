import Foundation
import Notifications
import NotificationsTesting
import Testing

struct FakeNotificationSchedulerTests {
  private func notification(_ id: String, at date: Date = .now) -> LocalNotification {
    LocalNotification(id: id, date: date, title: "", body: "", hiddenPreviewsBody: "")
  }

  @Test func asksOnlyOnce() async {
    let scheduler = FakeNotificationScheduler(answer: .denied)

    #expect(await scheduler.requestAuthorization() == .denied)
    #expect(await scheduler.authorization() == .denied)
  }

  @Test func keepsAnAnswerGivenBefore() async {
    let scheduler = FakeNotificationScheduler(authorization: .authorized, answer: .denied)

    #expect(await scheduler.requestAuthorization() == .authorized)
  }

  @Test func replacesOnlyThePrefix() async {
    let scheduler = FakeNotificationScheduler(authorization: .authorized)
    await scheduler.replacePending(withPrefix: "a-", by: [notification("a-1")])
    await scheduler.replacePending(withPrefix: "b-", by: [notification("b-1")])

    await scheduler.replacePending(withPrefix: "a-", by: [notification("a-2")])

    #expect(await scheduler.pending().map(\.id).sorted() == ["a-2", "b-1"])
  }

  @Test func schedulesNothingWithoutPermission() async {
    let scheduler = FakeNotificationScheduler(authorization: .denied)

    await scheduler.replacePending(withPrefix: "a-", by: [notification("a-1")])

    #expect(await scheduler.pending().isEmpty)
  }

  @Test func listsTheEarliestFirst() async {
    let scheduler = FakeNotificationScheduler(authorization: .authorized)
    let now = Date.now

    await scheduler.replacePending(
      withPrefix: "a-",
      by: [notification("a-2", at: now.addingTimeInterval(60)), notification("a-1", at: now)])

    #expect(await scheduler.pending().map(\.id) == ["a-1", "a-2"])
  }
}
