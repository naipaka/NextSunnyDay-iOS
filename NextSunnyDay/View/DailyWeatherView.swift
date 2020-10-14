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
        HStack {
            Spacer()
                .frame(width: 24)
            VStack {
                Spacer()
                    .frame(height: 14)
                viewModel.output.icon.image
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(viewModel.output.description)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
            }
            .foregroundColor(viewModel.output.icon.color)
            Spacer()
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
        .cornerRadius(15)
    }
}

struct DailyWeatherView_Previews: PreviewProvider {
    static var contentView: some View {
        Group {
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 800), description: "快晴"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 801), description: "晴れ"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 803), description: "曇り"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 804), description: "暑い雲"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 500), description: "天気雨"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 511), description: "雪"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 300), description: "雨"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 200), description: "雷雨"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 701), description: "竜巻"))
            DailyWeatherView(viewModel: MockViewModel(icon: WeatherIcon(code: 0), description: "-"))
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
            @Published var description: String = R.string.dailyWeather.hyphen()
            @Published var date: String = R.string.dailyWeather.hyphen()
            @Published var maxTemperature: String = R.string.dailyWeather.hyphen()
            @Published var minTemperature: String = R.string.dailyWeather.hyphen()
        }

        var input: Input

        var binding: Binding

        var output: Output

        init(icon: WeatherIcon, description: String) {
            let input = Input()
            let binding = Binding()
            let output = Output()

            // output
            output.icon = icon
            output.description = description
            output.date = "12/22 (火)"
            output.maxTemperature = "11.0℃"
            output.minTemperature = "2.0℃"

            self.input = input
            self.binding = binding
            self.output = output
        }
    }
}
