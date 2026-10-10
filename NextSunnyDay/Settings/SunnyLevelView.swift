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
        ForEach(SunnyLevel.cumulative, id: \.self, content: row)
      } footer: {
        Text("Lower levels are looser.")
      }
      Section {
        row(.laundry)
      } footer: {
        Text(
          "For drying laundry outside: judged by the forecast from 7:00 to 19:00, on days without rain."
        )
      }
    }
    .navigationTitle("What Counts as Sunny")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func row(_ level: SunnyLevel) -> some View {
    Button {
      sunnyLevelSelection.select(level)
    } label: {
      HStack(spacing: 14) {
        level.symbol
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
}

extension SunnyLevel {
  var title: LocalizedStringResource {
    switch self {
    case .clear: "Clear only"
    case .mostlyClear: "Sunny"
    case .partlyCloudy: "Up to partly cloudy"
    case .noRain: "No rain is fine"
    case .laundry: "Laundry day"
    }
  }

  /// The conditions that count, by the names Home shows; the loosest level and the laundry day
  /// describe them instead of listing nine.
  var detail: Text {
    switch self {
    case .noRain: Text("Cloudy days too, with a chance of rain under 30%")
    case .laundry:
      Text("Up to partly cloudy, chance of rain under 20%, humidity 60% or less, little wind")
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

  @ViewBuilder var symbol: some View {
    switch self {
    case .clear: WeatherSymbol(name: "sun.max")
    case .mostlyClear: WeatherSymbol(name: "sun.min")
    case .partlyCloudy: WeatherSymbol(name: "cloud.sun")
    case .noRain: WeatherSymbol(name: "cloud")
    case .laundry:
      // Yellow like the sun; cyan would read as rain.
      Image(systemName: "tshirt.fill")
        .foregroundStyle(.yellow)
        .accessibilityHidden(true)
    }
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { SunnyLevelView() }
  }
}
