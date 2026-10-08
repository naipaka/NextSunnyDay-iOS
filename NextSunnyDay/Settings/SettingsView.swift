import Region
import SwiftUI

/// The settings sheet: region, sunny level and the weather data note.
struct SettingsView: View {
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(RegionForecast.self) private var regionForecast
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(\.dismiss) private var dismiss

  private enum Route: Hashable {
    case region, sunnyLevel, about
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          NavigationLink(value: Route.region) {
            LabeledContent {
              regionName
            } label: {
              Label("Region", systemImage: "location.fill")
            }
          }
        }
        Section {
          NavigationLink(value: Route.sunnyLevel) {
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
          NavigationLink(value: Route.about) {
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
      .navigationDestination(for: Route.self) { route in
        switch route {
        case .region: RegionView()
        case .sunnyLevel: SunnyLevelView()
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

  private var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }
}

#Preview {
  PreviewHost(.tokyo) {
    SettingsView()
  }
}
