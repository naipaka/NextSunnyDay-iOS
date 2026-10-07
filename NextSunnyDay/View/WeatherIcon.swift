import SwiftUI
import WeatherKit

struct WeatherIcon {
  var image: Image
  var color: Color
}

extension WeatherIcon {
  static let unknown = WeatherIcon(
    image: Image(systemName: "questionmark.circle.fill"), color: Color(.black))

  init(_ forecast: DailyForecast) {
    image = Image(systemName: forecast.symbolName)
    color = Self.color(for: forecast.condition)
  }

  private static func color(for condition: WeatherCondition) -> Color {
    switch condition {
    case .clear, .mostlyClear, .partlyCloudy, .hot:
      Color(.orange)
    case .mostlyCloudy:
      Color(.gray)
    case .cloudy:
      Color(.darkGray)
    case .drizzle, .rain, .sunShowers:
      Color(ColorResource.blue)  // the "Blue" asset, not UIColor.blue
    case .heavyRain:
      Color(.darkBlue)
    case .flurries, .sunFlurries, .snow, .heavySnow, .blizzard, .blowingSnow, .sleet,
      .freezingRain, .freezingDrizzle, .wintryMix, .hail, .frigid:
      Color(.lightBlue)
    case .isolatedThunderstorms, .scatteredThunderstorms, .thunderstorms, .strongStorms,
      .tropicalStorm, .hurricane:
      Color(.boltYellow)
    case .foggy, .haze, .smoky, .blowingDust, .breezy, .windy:
      Color(.brown)
    @unknown default:
      Color(.black)
    }
  }
}
