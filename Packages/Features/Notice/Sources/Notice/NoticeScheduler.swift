import Foundation
public import Notifications
import Weather

/// Schedules the notifications of one region, replacing the ones scheduled before, and asks for
/// permission.
public struct NoticeScheduler: Sendable {
  /// Every notice's ID starts with it, so they are replaced together.
  static let idPrefix = "sunny-day-"
  /// The `userInfo` key holding the region's ID.
  static let regionKey = "region"

  private let notifications: any NotificationScheduling

  /// The system's notifications.
  public init() {
    self.init(notifications: UserNotificationScheduler())
  }

  public init(notifications: any NotificationScheduling) {
    self.notifications = notifications
  }

  public func authorization() async -> NotificationAuthorization {
    await notifications.authorization()
  }

  /// Asks for permission when the user hasn't been asked yet.
  public func requestAuthorization() async -> NotificationAuthorization {
    await notifications.requestAuthorization()
  }

  /// Replaces the scheduled notices with `notices` for the region with `regionID`, worded by
  /// `text`. An empty list cancels them.
  public func schedule(
    _ notices: [Notice], regionID: String, text: (Notice) -> NoticeText
  ) async {
    let calendar = Calendar(identifier: .gregorian)
    let scheduled = notices.map { notice in
      let text = text(notice)
      let day = calendar.dateComponents(in: .current, from: notice.day.date)
      let id = String(
        format: "%@%04d-%02d-%02d", Self.idPrefix, day.year ?? 0, day.month ?? 0, day.day ?? 0)
      return LocalNotification(
        id: id, date: notice.date, title: text.title, body: text.body,
        hiddenPreviewsBody: text.hiddenPreviewsBody, userInfo: [Self.regionKey: regionID])
    }
    await notifications.replacePending(withPrefix: Self.idPrefix, by: scheduled)
  }

  /// Cancels every scheduled notice.
  public func cancel() async {
    await notifications.replacePending(withPrefix: Self.idPrefix, by: [])
  }

  /// The region of a notice the user opened, from its `userInfo`.
  public static func regionID(in userInfo: [String: String]) -> String? {
    userInfo[regionKey]
  }
}

/// What a notice says, in the app's words.
public struct NoticeText: Sendable {
  public var title: String
  public var body: String
  /// Shown instead when the user hides notification previews.
  public var hiddenPreviewsBody: String

  public init(title: String, body: String, hiddenPreviewsBody: String) {
    self.title = title
    self.body = body
    self.hiddenPreviewsBody = hiddenPreviewsBody
  }
}
