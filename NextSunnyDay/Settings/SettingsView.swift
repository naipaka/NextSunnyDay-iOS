import Notice
import Region
import SwiftUI
import Units

/// The settings sheet: region, sunny level, notifications, temperature unit and the weather data
/// note.
struct SettingsView: View {
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(RegionForecast.self) private var regionForecast
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection
  @Environment(NoticeSelection.self) private var noticeSelection
  @Environment(\.dismiss) private var dismiss
  @State private var path: [SettingsRoute]

  /// - Parameter route: A screen to open at once, such as the notification settings when the
  ///   system's settings ask for them.
  init(route: SettingsRoute? = nil) {
    _path = State(initialValue: route.map { [$0] } ?? [])
  }

  var body: some View {
    NavigationStack(path: $path) {
      Form {
        Section {
          NavigationLink(value: SettingsRoute.region) {
            LabeledContent {
              regionName
            } label: {
              Label("Region", systemImage: "location.fill")
            }
          }
        }
        Section {
          NavigationLink(value: SettingsRoute.sunnyLevel) {
            LabeledContent {
              Text(sunnyLevelSelection.level.title)
            } label: {
              Label("What Counts as Sunny", systemImage: "sun.max.fill")
            }
          }
        } footer: {
          Text("Choose which kinds of days count as sunny.")
        }
        Section {
          NavigationLink(value: SettingsRoute.notifications) {
            LabeledContent {
              if noticeSelection.isOn {
                Text(verbatim: noticeSelection.setting.time.formatted)
              } else {
                Text("Off")
              }
            } label: {
              Label("Notifications", systemImage: "bell.fill")
            }
          }
        }
        Section {
          Picker(selection: temperatureUnit) {
            ForEach(TemperatureUnitSetting.allCases, id: \.self) { setting in
              Text(setting.title)
            }
          } label: {
            Label("Temperature", systemImage: "thermometer.medium")
          } currentValueLabel: {
            // The unit in use, like the other units in the Weather app; the choices spell it out.
            Text(verbatim: temperatureUnitSelection.unit.symbol)
          }
        }
        Section {
          NavigationLink(value: SettingsRoute.about) {
            Label("About Weather Data", systemImage: "info.circle")
          }
        } footer: {
          Text("NextSunnyDay version \(version)")
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) { dismiss() }
        }
      }
      .navigationDestination(for: SettingsRoute.self) { route in
        switch route {
        case .region: RegionListView()
        case .sunnyLevel: SunnyLevelView()
        case .notifications: NotificationsView()
        case .about: AboutView()
        }
      }
    }
  }

  @ViewBuilder private var regionName: some View {
    if let name = regionSelection.region?.placeName {
      Text(verbatim: name)
    } else if regionSelection.region != nil {
      Text("Current Location")
    }
  }

  /// Changes go through the state holder, which saves them and reloads the widgets.
  private var temperatureUnit: Binding<TemperatureUnitSetting> {
    Binding(
      get: { temperatureUnitSelection.setting },
      set: { temperatureUnitSelection.select($0) })
  }

  private var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }
}

/// The screens Settings pushes.
enum SettingsRoute: Hashable {
  case region, sunnyLevel, notifications, about
}

#Preview {
  PreviewHost(.tokyo) {
    SettingsView()
  }
}

extension TemperatureUnitSetting {
  /// The names Apple's Weather app uses for its temperature units; the system setting shows the
  /// unit it gives now, such as "Use System Setting (°C)".
  var title: LocalizedStringResource {
    switch self {
    case .system: "Use System Setting (\(unit(for: .current).symbol))"
    case .celsius: "Celsius (°C)"
    case .fahrenheit: "Fahrenheit (°F)"
    }
  }
}
