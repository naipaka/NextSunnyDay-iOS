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

  // The completion handler versions, called back on the main thread: with the async versions the
  // system's completion ran off the main thread when a notification was opened, and UIKit
  // stopped the app on an assertion.

  /// While the app is open, a notification goes to Notification Center without a banner: the app
  /// already shows the forecast.
  nonisolated public func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let completion = Completion(call: completionHandler)
    DispatchQueue.main.async {
      completion.call([.list])
    }
  }

  nonisolated public func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let isOpened = response.actionIdentifier == UNNotificationDefaultActionIdentifier
    let userInfo = response.notification.request.content.userInfo.stringValues
    let completion = Completion(call: completionHandler)
    DispatchQueue.main.async {
      MainActor.assumeIsolated {
        if isOpened {
          self.onOpen(userInfo)
        }
      }
      completion.call(())
    }
  }

  nonisolated public func userNotificationCenter(
    _ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?
  ) {
    Task { @MainActor in onOpenSettings() }
  }
}

/// A completion handler of the system's, passed to the main thread. `@unchecked` because the
/// handler isn't marked `Sendable`; the system lets it be called from any thread.
private struct Completion<Value>: @unchecked Sendable {
  let call: (Value) -> Void
}
