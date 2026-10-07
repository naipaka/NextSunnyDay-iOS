import SwiftUI
import WeatherKit

struct DailyWeatherView<T>: View where T: DailyWeatherViewModelObject {
  @ObservedObject private var viewModel: T

  init(viewModel: T) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      Color(.tertiarySystemBackground).edgesIgnoringSafeArea(.all)
      HStack {
        Spacer()
          .frame(width: 24)
        VStack {
          Spacer()
            .frame(height: 14)
          viewModel.output.icon.image
            .resizable()
            .symbolVariant(.fill)
            .frame(width: 30, height: 30)
            .foregroundColor(viewModel.output.icon.color)
          Text(viewModel.output.weatherDescription)
            .fixedSize()
        }
        .frame(width: 32)
        Spacer().frame(maxWidth: 24)
        Text(viewModel.output.date)
          .font(.system(size: 28))
          .fixedSize()
        Spacer()
        VStack {
          Text(viewModel.output.maxTemperature)
            .font(.system(size: 14))
            .foregroundColor(Color(.systemRed))
          Spacer()
            .frame(height: 8)
          Text(viewModel.output.minTemperature)
            .font(.system(size: 14))
            .foregroundColor(Color(.systemBlue))
        }
        Spacer()
          .frame(width: 24)
      }
    }
    .cornerRadius(15)
  }
}

struct DailyWeatherView_Previews: PreviewProvider {
  private static let samples: [(WeatherCondition, String)] = [
    (.clear, "sun.max"),
    (.mostlyClear, "sun.min"),
    (.mostlyCloudy, "cloud.sun"),
    (.cloudy, "cloud"),
    (.rain, "cloud.rain"),
    (.snow, "cloud.snow"),
    (.drizzle, "cloud.drizzle"),
    (.thunderstorms, "cloud.bolt.rain"),
    (.foggy, "cloud.fog"),
  ]

  static var contentView: some View {
    Group {
      ForEach(samples, id: \.0) { condition, symbolName in
        DailyWeatherView(
          viewModel: MockViewModel(
            forecast: .sample(date: Date(), condition: condition, symbolName: symbolName)))
      }
      DailyWeatherView(viewModel: MockViewModel(icon: .unknown, weatherDescription: "-"))
    }
  }

  static var previews: some View {
    Group {
      // 320pt × 568pt (iPhone SE 第1世代)
      contentView
        .previewLayout(.fixed(width: 291.0, height: 82.0))

      //            // 375pt × 667pt (iPhone 6/6s/7/7s/8/SE 第2世代)
      //            contentView
      //                .previewLayout(.fixed(width: 322.0, height: 82.0))
      //
      //            // 414pt × 736pt (iPhone 6 Plus/6s Plus/7 Plus/8 Plus)
      //            contentView
      //                .previewLayout(.fixed(width: 348.0, height: 82.0))
      //
      //            // 375pt × 812pt (iPhone X/XS/11 Pro)
      //            contentView
      //                .previewLayout(.fixed(width: 329.0, height: 82.0))
      //
      //            // 414pt × 896pt (iPhone XR/XS Max/11/11 Pro Max)
      //            contentView
      //                .previewLayout(.fixed(width: 360.0, height: 82.0))
    }
  }
}

extension DailyWeatherView_Previews {
  final class MockViewModel: DailyWeatherViewModelObject {
    final class Input: DailyWeatherViewModelInputObject {}

    final class Binding: DailyWeatherViewModelBindingObject {}

    final class Output: DailyWeatherViewModelOutputObject {
      @Published var icon = WeatherIcon.unknown
      @Published var weatherDescription: String = "-"
      @Published var date: String = "-"
      @Published var maxTemperature: String = "-"
      @Published var minTemperature: String = "-"
    }

    var input: Input

    var binding: Binding

    var output: Output

    convenience init(forecast: DailyForecast) {
      self.init(icon: WeatherIcon(forecast), weatherDescription: forecast.condition.description)
    }

    init(icon: WeatherIcon, weatherDescription: String) {
      let input = Input()
      let binding = Binding()
      let output = Output()

      // output
      output.icon = icon
      output.weatherDescription = weatherDescription
      output.date = "12/22 (火)"
      output.maxTemperature = "11.0℃"
      output.minTemperature = "2.0℃"

      self.input = input
      self.binding = binding
      self.output = output
    }
  }
}
