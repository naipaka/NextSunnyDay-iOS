import Notice
import Notifications
import Region
import SwiftUI

/// Turns the notification before a sunny day on and off, and chooses its region and time.
struct NotificationsView: View {
  @Environment(NoticeSelection.self) private var noticeSelection
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(\.openURL) private var openURL

  var body: some View {
    Form {
      Section {
        Toggle("Notify the Day Before", isOn: isOn)
        if noticeSelection.isOn {
          Picker("Region", selection: regionID) {
            ForEach(regionSelection.regions) { region in
              regionName(region).tag(region.id)
            }
          }
          DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
        }
      } footer: {
        Text(
          "Get a notification the day before a sunny day, at this time. None while the sunny days continue."
        )
      }
      if noticeSelection.authorization == .denied {
        Section {
          Button("Open Settings") {
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
              openURL(url)
            }
          }
        } footer: {
          Text("Notifications are off for this app. Turn them on in Settings to get them.")
        }
      }
    }
    .navigationTitle("Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await noticeSelection.refreshAuthorization()
    }
  }

  @ViewBuilder private func regionName(_ region: SavedRegion) -> some View {
    if let name = region.placeName {
      Text(verbatim: name)
    } else {
      Text("Current Location")
    }
  }

  /// Turning it on asks for permission the first time.
  private var isOn: Binding<Bool> {
    Binding(
      get: { noticeSelection.isOn },
      set: { isOn in
        if isOn {
          Task { await noticeSelection.turnOn() }
        } else {
          noticeSelection.turnOff()
        }
      })
  }

  /// The chosen region, or the first one until the user chooses or after it is removed.
  private var regionID: Binding<String> {
    Binding(
      get: { regionSelection.list.region(id: noticeSelection.setting.regionID)?.id ?? "" },
      set: { noticeSelection.selectRegion(id: $0) })
  }

  private var time: Binding<Date> {
    Binding(
      get: { noticeSelection.setting.time.date() },
      set: { noticeSelection.selectTime(NoticeTime($0)) })
  }
}

extension NoticeTime {
  /// The hour and minute of `date`.
  init(_ date: Date, calendar: Calendar = .current) {
    let components = calendar.dateComponents([.hour, .minute], from: date)
    self.init(hour: components.hour ?? 0, minute: components.minute ?? 0)
  }

  /// This time on the day of `day`.
  func date(on day: Date = .now, calendar: Calendar = .current) -> Date {
    calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
  }

  /// Such as `19:00`, in the format the system uses for the language.
  var formatted: String {
    date().formatted(date: .omitted, time: .shortened)
  }
}

#Preview("On") {
  PreviewHost(.notificationsOn) {
    NavigationStack {
      NotificationsView()
    }
  }
}

#Preview("Denied") {
  PreviewHost(.notificationsDenied) {
    NavigationStack {
      NotificationsView()
    }
  }
}
