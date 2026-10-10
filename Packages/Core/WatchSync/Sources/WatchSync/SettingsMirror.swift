public import Foundation

/// Copies settings kept in `UserDefaults` from the iPhone to the watch, in the format they are
/// stored in: the iPhone reads the values of some keys into a context, and the watch writes the
/// context into its own `UserDefaults`, where the same stores read them.
///
/// `@unchecked` because `UserDefaults` is not marked `Sendable`, although it is thread-safe.
public struct SettingsMirror: @unchecked Sendable {
  /// The keys that are copied.
  public let keys: [String]
  private let defaults: UserDefaults

  public init(keys: [String], defaults: UserDefaults) {
    self.keys = keys
    self.defaults = defaults
  }

  /// The stored values of the keys. A key without a value is left out, so that the watch removes
  /// it too.
  public func context() -> [String: Any] {
    var context: [String: Any] = [:]
    for key in keys {
      if let value = defaults.object(forKey: key) {
        context[key] = value
      }
    }
    return context
  }

  /// Writes the values of the keys from `context` and removes the keys it doesn't have. Other keys
  /// in `context` are ignored.
  ///
  /// - Returns: Whether a value changed.
  @discardableResult
  public func apply(_ context: [String: Any]) -> Bool {
    var changed = false
    for key in keys {
      let old = defaults.object(forKey: key) as AnyObject?
      let new = context[key] as AnyObject?
      guard !Self.isEqual(old, new) else { continue }
      changed = true
      if let new {
        defaults.set(new, forKey: key)
      } else {
        defaults.removeObject(forKey: key)
      }
    }
    return changed
  }

  private static func isEqual(_ lhs: AnyObject?, _ rhs: AnyObject?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil): true
    case (let lhs?, let rhs?): lhs.isEqual(rhs)
    default: false
    }
  }
}
