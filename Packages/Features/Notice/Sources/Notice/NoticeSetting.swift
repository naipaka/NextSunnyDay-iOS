/// Whether, for which region and at what time the user is told about a sunny day the day before.
public struct NoticeSetting: Equatable, Sendable {
  public var isOn: Bool
  /// The region notified about; `nil` for the first saved region, which is also used after the
  /// chosen one is removed.
  public var regionID: String?
  public var time: NoticeTime

  /// Off, for the first region, at 19:00.
  public static let `default` = NoticeSetting(isOn: false, regionID: nil, time: .default)

  public init(isOn: Bool, regionID: String?, time: NoticeTime) {
    self.isOn = isOn
    self.regionID = regionID
    self.time = time
  }
}

/// A time of day, in the device's time zone.
public struct NoticeTime: Hashable, Sendable {
  public var hour: Int
  public var minute: Int

  /// 19:00: the evening, when the next day is planned.
  public static let `default` = NoticeTime(hour: 19, minute: 0)

  public init(hour: Int, minute: Int) {
    self.hour = hour
    self.minute = minute
  }

  /// Minutes after midnight, as stored.
  var minutes: Int { hour * 60 + minute }

  init?(minutes: Int) {
    guard (0..<(24 * 60)).contains(minutes) else { return nil }
    self.init(hour: minutes / 60, minute: minutes % 60)
  }
}
