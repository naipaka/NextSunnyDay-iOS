import Foundation
import UserNotifications

/// Schedules notifications with `UNUserNotificationCenter`. Works in the app and in its
/// extensions, which notify on the app's behalf.
public struct UserNotificationScheduler: NotificationScheduling {
  private var center: UNUserNotificationCenter { .current() }

  public init() {}

  public func authorization() async -> NotificationAuthorization {
    NotificationAuthorization(await center.notificationSettings().authorizationStatus)
  }

  public func requestAuthorization() async -> NotificationAuthorization {
    // `providesAppNotificationSettings` links the system's notification settings for the app to
    // the app's own (`NotificationResponder.onOpenSettings`).
    _ = try? await center.requestAuthorization(
      options: [.alert, .sound, .providesAppNotificationSettings])
    return await authorization()
  }

  public func replacePending(withPrefix prefix: String, by notifications: [LocalNotification])
    async
  {
    let replaced = await center.pendingNotificationRequests()
      .map(\.identifier)
      .filter { $0.hasPrefix(prefix) }
    center.removePendingNotificationRequests(withIdentifiers: replaced)
    guard !notifications.isEmpty else { return }

    // The text shown with hidden previews belongs to a category.
    let categories = Set(notifications.map(\.hiddenPreviewsBody)).map {
      UNNotificationCategory(
        identifier: Self.categoryID($0), actions: [], intentIdentifiers: [],
        hiddenPreviewsBodyPlaceholder: $0)
    }
    center.setNotificationCategories(Set(categories))
    for notification in notifications {
      try? await center.add(request(for: notification))
    }
  }

  public func pending() async -> [LocalNotification] {
    await center.pendingNotificationRequests()
      .compactMap(LocalNotification.init)
      .sorted { $0.date < $1.date }
  }

  private func request(for notification: LocalNotification) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = notification.title
    content.body = notification.body
    content.sound = .default
    content.categoryIdentifier = Self.categoryID(notification.hiddenPreviewsBody)
    content.userInfo = notification.userInfo
    // Without a time zone the date stays at the same local time if the device moves to another
    // time zone, like an alarm.
    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: notification.date)
    return UNNotificationRequest(
      identifier: notification.id, content: content,
      trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
  }

  static func categoryID(_ hiddenPreviewsBody: String) -> String {
    "hidden-previews:\(hiddenPreviewsBody)"
  }
}

extension NotificationAuthorization {
  init(_ status: UNAuthorizationStatus) {
    switch status {
    case .notDetermined: self = .notDetermined
    case .denied: self = .denied
    default: self = .authorized
    }
  }
}

extension LocalNotification {
  fileprivate init?(_ request: UNNotificationRequest) {
    guard
      let trigger = request.trigger as? UNCalendarNotificationTrigger,
      let date = trigger.nextTriggerDate()
    else { return nil }
    let placeholder = request.content.categoryIdentifier
      .replacing("hidden-previews:", with: "", maxReplacements: 1)
    self.init(
      id: request.identifier, date: date, title: request.content.title,
      body: request.content.body, hiddenPreviewsBody: placeholder,
      userInfo: request.content.userInfo.stringValues)
  }
}

extension [AnyHashable: Any] {
  var stringValues: [String: String] {
    reduce(into: [:]) { result, element in
      if let key = element.key as? String, let value = element.value as? String {
        result[key] = value
      }
    }
  }
}
