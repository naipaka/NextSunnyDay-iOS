#if canImport(WatchConnectivity)
  public import Foundation
  public import WatchConnectivity

  /// Keeps the watch's copy of the settings up to date through WatchConnectivity's application
  /// context: the system keeps only the latest one, and delivers it when the watch app runs or
  /// wakes it in the background.
  ///
  /// The iPhone sends the values of the mirror's keys; the watch writes them into its own
  /// `UserDefaults` and calls `onChange` when something changed.
  ///
  /// `@unchecked` because the session calls its delegate on a queue of its own; the properties
  /// never change after `init`.
  public final class SettingsSync: NSObject, WCSessionDelegate, @unchecked Sendable {
    private let mirror: SettingsMirror
    private let onChange: @Sendable () -> Void

    /// - Parameter onChange: Called on the watch, on a background queue, after a received value
    ///   changed what is stored.
    public init(mirror: SettingsMirror, onChange: @escaping @Sendable () -> Void = {}) {
      self.mirror = mirror
      self.onChange = onChange
    }

    /// Starts the session. The iPhone then sends the current values; the watch applies the last
    /// values it received.
    public func activate() {
      guard WCSession.isSupported() else { return }
      WCSession.default.delegate = self
      WCSession.default.activate()
    }

    #if os(iOS)
      /// Sends the current values when a watch with the app is paired.
      public func send() {
        let session = WCSession.default
        guard WCSession.isSupported(), session.activationState == .activated, session.isPaired,
          session.isWatchAppInstalled
        else { return }
        try? session.updateApplicationContext(mirror.context())
      }
    #endif

    #if os(watchOS)
      /// Returns when everything the iPhone sent has been delivered. A background task for
      /// WatchConnectivity keeps the app running until then.
      public func waitForPendingContent() async {
        while WCSession.default.hasContentPending, !Task.isCancelled {
          try? await Task.sleep(for: .milliseconds(200))
        }
      }
    #endif

    // MARK: - WCSessionDelegate

    public func session(
      _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
      error: (any Error)?
    ) {
      guard activationState == .activated else { return }
      #if os(iOS)
        send()
      #else
        receive(session.receivedApplicationContext)
      #endif
    }

    public func session(
      _ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]
    ) {
      receive(applicationContext)
    }

    #if os(iOS)
      public func sessionDidBecomeInactive(_ session: WCSession) {}

      /// The user switched to another watch; the session starts again for it.
      public func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
      }

      /// The app may have been installed on the watch since the last send.
      public func sessionWatchStateDidChange(_ session: WCSession) {
        send()
      }
    #endif

    private func receive(_ context: [String: Any]) {
      // Empty until the iPhone sent something; nothing to remove then.
      guard !context.isEmpty, mirror.apply(context) else { return }
      onChange()
    }
  }
#endif
