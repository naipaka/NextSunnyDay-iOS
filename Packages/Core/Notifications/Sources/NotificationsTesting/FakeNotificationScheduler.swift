import Foundation
import Notifications
import Synchronization

/// A `NotificationScheduling` that keeps the pending notifications in memory, with the permission
/// the user would give.
public final class FakeNotificationScheduler: NotificationScheduling {
  private struct State {
    var authorization: NotificationAuthorization
    var answer: NotificationAuthorization
    var pending: [LocalNotification] = []
  }

  private let state: Mutex<State>

  /// - Parameters:
  ///   - authorization: The permission so far.
  ///   - answer: What the user answers when asked.
  public init(
    authorization: NotificationAuthorization = .notDetermined,
    answer: NotificationAuthorization = .authorized
  ) {
    state = Mutex(State(authorization: authorization, answer: answer))
  }

  public func authorization() async -> NotificationAuthorization {
    state.withLock(\.authorization)
  }

  public func requestAuthorization() async -> NotificationAuthorization {
    state.withLock { state in
      if state.authorization == .notDetermined {
        state.authorization = state.answer
      }
      return state.authorization
    }
  }

  public func replacePending(withPrefix prefix: String, by notifications: [LocalNotification])
    async
  {
    state.withLock { state in
      state.pending.removeAll { $0.id.hasPrefix(prefix) }
      // The system schedules nothing without permission.
      guard state.authorization == .authorized else { return }
      for notification in notifications {
        state.pending.removeAll { $0.id == notification.id }
        state.pending.append(notification)
      }
    }
  }

  public func pending() async -> [LocalNotification] {
    state.withLock(\.pending).sorted { $0.date < $1.date }
  }
}
