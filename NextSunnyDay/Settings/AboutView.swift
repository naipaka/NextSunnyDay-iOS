import Forecast
import SunnyDay
import SwiftUI
import Weather

/// Where the weather data comes from, and what the current sunny level counts.
struct AboutView: View {
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(\.forecastUpdater) private var forecastUpdater
  @State private var attribution: WeatherDataAttribution?

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 12) {
          if let attribution {
            AttributionMark(attribution: attribution)
              .frame(height: 20)
          }
          Text(
            "The forecast uses data from Apple Weather. It is updated once a day in the early morning, and you can update it yourself by pulling down on the home screen."
          )
          .font(.subheadline)
          .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        if let attribution {
          Link("Data Sources and Legal Information", destination: attribution.legalPageURL)
        }
      }
      Section {
        LabeledContent {
          Text(sunnyLevelSelection.level.title)
        } label: {
          Text("What Counts as Sunny")
        }
        LabeledContent {
          Text(verbatim: countedConditions)
        } label: {
          Text("Weather That Counts")
        }
      } header: {
        Text("Current Settings")
      } footer: {
        Text("You can change what counts as sunny in Settings.")
      }
    }
    .navigationTitle("About Weather Data")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      attribution = try? await forecastUpdater.attribution()
    }
  }

  private var countedConditions: String {
    WeatherCondition.allCases
      .filter { sunnyLevelSelection.level.conditions.contains($0) }
      .map(\.localizedName)
      .formatted(.list(type: .and))
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { AboutView() }
  }
}
