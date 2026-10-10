import Foundation
import Notice
import Notifications
import Observation

/// Whether, for which region and when the user is told about a sunny day the day before, and
/// whether the system lets the app notify.
@Observable
final class NoticeSelection {
  private(set) var setting: NoticeSetting
  /// `nil` until it is checked.
  private(set) var authorization: NotificationAuthorization?
  /// Set when the system's notification settings open the app's; Home then shows them.
  var isSettingsRequested = false

  @ObservationIgnored private let features: AppFeatures

  init(features: AppFeatures) {
    self.features = features
    setting = features.noticeStore.load()
  }

  /// On only while the system lets the app notify, so that the switch shows what will happen.
  var isOn: Bool { setting.isOn && authorization != .denied }

  /// Checks the permission again; the user may have changed it in the system's settings.
  func refreshAuthorization() async {
    authorization = await features.noticeScheduler.authorization()
  }

  /// Turns notifications on, asking for permission the first time. They stay off when the user
  /// doesn't allow them.
  func turnOn() async {
    let authorization = await features.noticeScheduler.requestAuthorization()
    self.authorization = authorization
    guard authorization == .authorized else { return }
    update { $0.isOn = true }
  }

  func turnOff() {
    update { $0.isOn = false }
  }

  /// The region to notify about; `nil` for the first saved one.
  func selectRegion(id: String?) {
    update { $0.regionID = id }
  }

  func selectTime(_ time: NoticeTime) {
    update { $0.time = time }
  }

  /// Schedules the notifications again from what is stored now. Views call it when anything
  /// they depend on changes.
  func reschedule(now: Date = .now) async {
    await features.scheduleNotices(now: now)
  }

  private func update(_ change: (inout NoticeSetting) -> Void) {
    var setting = setting
    change(&setting)
    guard setting != self.setting else { return }
    self.setting = setting
    features.noticeStore.save(setting)
  }
}
