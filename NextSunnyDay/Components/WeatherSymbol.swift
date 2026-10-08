import SwiftUI

/// A weather SF Symbol in the palette colors of the design: gray or white clouds, a yellow sun
/// and moon, cyan rain.
struct WeatherSymbol: View {
  /// The symbol name; WeatherKit's names are used with their filled variant.
  let name: String

  private var cloud: Color {
    Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? .white : .systemGray2 })
  }

  private var filledName: String {
    name.hasSuffix(".fill") ? name : "\(name).fill"
  }

  var body: some View {
    let image = Image(systemName: filledName).symbolRenderingMode(.palette)
    if filledName.hasPrefix("sun") || filledName.hasPrefix("moon") {
      image.foregroundStyle(.yellow, .yellow)
    } else if filledName.hasPrefix("cloud.sun") || filledName.hasPrefix("cloud.moon") {
      image.foregroundStyle(cloud, .yellow)
    } else if filledName == "cloud.fill" {
      image.foregroundStyle(cloud)
    } else {
      image.foregroundStyle(cloud, .cyan)
    }
  }
}

#Preview {
  HStack {
    ForEach(
      ["sun.max", "sun.min", "cloud.sun", "cloud", "cloud.rain", "cloud.drizzle", "moon.stars"],
      id: \.self
    ) {
      WeatherSymbol(name: $0)
    }
  }
  .font(.largeTitle)
}
