public import Foundation

/// Schedules local notifications. `UserNotificationScheduler` is the real one;
/// `NotificationsTesting` has a fake.
public protocol NotificationScheduling: Sendable {
  /// Whether the app may notify the user.
  func authorization() async -> NotificationAuthorization

  /// Asks the user for permission when they haven't been asked yet, and returns the result.
  func requestAuthorization() async -> NotificationAuthorization

  /// Replaces the pending notifications whose IDs start with `prefix` with `notifications`.
  /// Notifications that were already delivered stay in Notification Center.
  func replacePending(withPrefix prefix: String, by notifications: [LocalNotification]) async

  /// The notifications waiting to be delivered, earliest first.
  func pending() async -> [LocalNotification]
}

public enum NotificationAuthorization: Equatable, Sendable {
  /// The user hasn't been asked yet.
  case notDetermined
  /// The user turned notifications off for the app.
  case denied
  /// Notifications may be shown, including provisionally.
  case authorized
}

/// A notification delivered once, at a date.
public struct LocalNotification: Equatable, Sendable {
  /// Scheduling another notification with the same ID replaces it.
  public var id: String
  /// When it is delivered, in the device's time zone at that moment.
  public var date: Date
  public var title: String
  public var body: String
  /// Shown instead of the title and body when the user hides notification previews.
  public var hiddenPreviewsBody: String
  /// Handed back when the user opens the notification.
  public var userInfo: [String: String]

  public init(
    id: String, date: Date, title: String, body: String, hiddenPreviewsBody: String,
    userInfo: [String: String] = [:]
  ) {
    self.id = id
    self.date = date
    self.title = title
    self.body = body
    self.hiddenPreviewsBody = hiddenPreviewsBody
    self.userInfo = userInfo
  }
}
