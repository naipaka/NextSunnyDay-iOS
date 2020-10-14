//
//  DailyWeatherView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import SwiftUI

struct DailyWeatherView<T>: View where T: DailyWeatherViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                    .frame(width: 24)
                VStack {
                    Spacer()
                        .frame(height: 14)
                    viewModel.output.icon.image
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(viewModel.output.icon.color)
                    Text(viewModel.output.weatherDescription)
                        .fontWeight(.semibold)
                        .fixedSize()
                }
                .frame(width: 32)
                Spacer().frame(maxWidth: 24)
                Text(viewModel.output.date)
                    .font(.system(size: 24))
                    .fixedSize()
                Spacer()
                VStack {
                    Text(viewModel.output.maxTemperature)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    Spacer()
                        .frame(height: 8)
                    Text(viewModel.output.minTemperature)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                Spacer()
                    .frame(width: 24)
            }
        }
        .cornerRadius(15)
    }
}

struct DailyWeatherView_Previews: PreviewProvider {
    static var contentView: some View {
        Group {
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 800), weatherDescription: "快晴"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 801), weatherDescription: "晴れ"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 803), weatherDescription: "曇り"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 804), weatherDescription: "暑い雲"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 500), weatherDescription: "天気雨"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 511), weatherDescription: "雪"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 300), weatherDescription: "雨"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 200), weatherDescription: "雷雨"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 701), weatherDescription: "竜巻"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 0), weatherDescription: "-"))
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
            @Published var icon = WeatherIcon(code: 0)
            @Published var weatherDescription: String = R.string.dailyWeather.hyphen()
            @Published var date: String = R.string.dailyWeather.hyphen()
            @Published var maxTemperature: String = R.string.dailyWeather.hyphen()
            @Published var minTemperature: String = R.string.dailyWeather.hyphen()
        }

        var input: Input

        var binding: Binding

        var output: Output

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
