public import Foundation
public import UserNotifications

/// Tells the app when the user opens one of its notifications, or opens the app's notification
/// settings from the system's. Keep one for the life of the app and call `activate()` before the
/// app finishes launching, so that a notification that launches the app reaches it.
@MainActor
public final class NotificationResponder: NSObject, UNUserNotificationCenterDelegate {
  /// The `userInfo` of the notification the user opened.
  public var onOpen: (_ userInfo: [String: String]) -> Void = { _ in }
  /// The user chose the app's notification settings in the system's.
  public var onOpenSettings: () -> Void = {}

  override public init() {}

  public func activate() {
    UNUserNotificationCenter.current().delegate = self
  }

  /// While the app is open, a notification goes to Notification Center without a banner: the app
  /// already shows the forecast.
  nonisolated public func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    [.list]
  }

  nonisolated public func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
  ) async {
    guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
    let userInfo = response.notification.request.content.userInfo.stringValues
    await MainActor.run { onOpen(userInfo) }
  }

  nonisolated public func userNotificationCenter(
    _ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?
  ) {
    Task { @MainActor in onOpenSettings() }
  }
}
