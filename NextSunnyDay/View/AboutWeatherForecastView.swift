import SwiftUI
import WeatherKit

struct AboutWeatherForecastView: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var attribution: WeatherAttribution?

  var body: some View {
    ZStack {
      Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
      VStack(alignment: .leading) {
        Text("This app shows information based on weather forecasts from Apple Weather.")
          .padding()
        Text(
          "We accept no responsibility for any loss or damage caused by the weather forecast information in this app."
        )
        .padding()
        if let attribution {
          attributionView(attribution)
            .padding()
        }
        Spacer()
      }
    }
    .font(.none)
    .navigationBarTitle("About Weather Forecast")
    .task {
      attribution = try? await WeatherService.shared.attribution
    }
  }
}

extension AboutWeatherForecastView {
  /// The Apple Weather mark and the link to the legal attribution page, as WeatherKit requires.
  fileprivate func attributionView(_ attribution: WeatherAttribution) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      AsyncImage(
        url: colorScheme == .dark
          ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL
      ) { image in
        image
          .resizable()
          .scaledToFit()
      } placeholder: {
        ProgressView()
      }
      .frame(height: 16)
      .accessibilityLabel(attribution.serviceName)
      Link(destination: attribution.legalPageURL) {
        Text("Other data sources")
          .foregroundColor(.secondary)
          .underline()
      }
    }
  }
}

struct AboutWeatherForecastView_Previews: PreviewProvider {
  static var previews: some View {
    AboutWeatherForecastView()
  }
}
