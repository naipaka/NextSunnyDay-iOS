import Forecast
import SwiftUI
import Weather

/// When the forecast was fetched, and the Apple Weather mark with its legal link, which WeatherKit
/// requires wherever its data is shown. The watch is always dark, so it uses the mark for dark
/// backgrounds.
struct AttributionFooter: View {
  var fetchedAt: Date?

  @Environment(\.forecastUpdater) private var forecastUpdater
  @State private var attribution: WeatherDataAttribution?

  var body: some View {
    VStack(spacing: 4) {
      if let fetchedAt {
        Text("Updated \(fetchedAt.fetchTime)")
      }
      if let attribution {
        AsyncImage(url: attribution.combinedMarkDarkURL) { image in
          image.resizable().scaledToFit()
        } placeholder: {
          Color.clear
        }
        .frame(height: 12)
        .accessibilityLabel(Text(verbatim: attribution.serviceName))
        Link("Data Sources", destination: attribution.legalPageURL)
          .buttonStyle(.plain)
          .underline()
      }
    }
    .font(.footnote)
    .opacity(0.85)
    .frame(maxWidth: .infinity)
    .task {
      attribution = try? await forecastUpdater.attribution()
    }
  }
}
