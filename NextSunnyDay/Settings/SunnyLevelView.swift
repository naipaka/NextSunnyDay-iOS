import SunnyDay
import SwiftUI
import Weather

/// Chooses which days count as sunny.
struct SunnyLevelView: View {
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @ScaledMetric private var symbolWidth: CGFloat = 34

  var body: some View {
    List {
      Section {
        ForEach(SunnyLevel.allCases, id: \.self) { level in
          Button {
            sunnyLevelSelection.select(level)
          } label: {
            HStack(spacing: 14) {
              WeatherSymbol(name: level.symbolName)
                .font(.title2)
                .frame(width: symbolWidth)
              VStack(alignment: .leading, spacing: 2) {
                Text(level.title)
                  .foregroundStyle(.primary)
                level.detail
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              if level == sunnyLevelSelection.level {
                Image(systemName: "checkmark")
                  .fontWeight(.semibold)
                  .foregroundStyle(.orange)
              }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      } footer: {
        Text(
          "Lower levels are looser. Looking for a day to dry the laundry? Try “No rain is fine”.")
      }
    }
    .navigationTitle("What Counts as Sunny")
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension SunnyLevel {
  var title: LocalizedStringResource {
    switch self {
    case .clear: "Clear only"
    case .mostlyClear: "Sunny"
    case .partlyCloudy: "Up to partly cloudy"
    case .noRain: "No rain is fine"
    }
  }

  /// The conditions that count, by the names Home shows; the loosest level describes them instead
  /// of listing nine.
  var detail: Text {
    switch self {
    case .noRain: Text("Cloudy days too, with a chance of rain under 30%")
    default: Text(verbatim: conditionNames)
    }
  }

  /// The names of the conditions that count, such as 「快晴、ほぼ快晴」.
  var conditionNames: String {
    WeatherCondition.allCases
      .filter { conditions.contains($0) }
      .map(\.localizedName)
      .formatted(.list(type: .and))
  }

  var symbolName: String {
    switch self {
    case .clear: "sun.max"
    case .mostlyClear: "sun.min"
    case .partlyCloudy: "cloud.sun"
    case .noRain: "cloud"
    }
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { SunnyLevelView() }
  }
}
