//
//  DailyWeatherViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

// MARK: - DailyWeatherViewModelObject
protocol DailyWeatherViewModelObject: ViewModelObject where Input: DailyWeatherViewModelInputObject, Binding: DailyWeatherViewModelBindingObject, Output: DailyWeatherViewModelOutputObject {
    var input: Input { get }
    var binding: Binding { get }
    var output: Output { get }
}

// MARK: - DailyWeatherViewModelInputObject
protocol DailyWeatherViewModelInputObject: InputObject {
}

// MARK: - DailyWeatherViewModelBindingObject
protocol DailyWeatherViewModelBindingObject: BindingObject {
}

// MARK: - DailyWeatherViewModelOutputObject
protocol DailyWeatherViewModelOutputObject: OutputObject {
    var icon: Image { get }
    var description: String { get }
    var date: String { get }
    var maxTemperature: String { get }
    var minTemperature: String { get }
}

// MARK: - DailyWeatherViewModel
class DailyWeatherViewModel: DailyWeatherViewModelObject {
    final class Input: DailyWeatherViewModelInputObject {}

    final class Binding: DailyWeatherViewModelBindingObject {}

    final class Output: DailyWeatherViewModelOutputObject {
        @Published var icon = Image(systemName: R.string.systemName.gearshapeFill())
        @Published var description: String = R.string.dailyWeather.hyphen()
        @Published var date: String = R.string.dailyWeather.hyphen()
        @Published var maxTemperature: String = R.string.dailyWeather.hyphen()
        @Published var minTemperature: String = R.string.dailyWeather.hyphen()
    }

    var input: Input

    var binding: Binding

    var output: Output

    init(_ daily: Daily) {
        let input = Input()
        let binding = Binding()
        let output = Output()

        // output
        output.icon = Image(systemName: WeatherConditionCode.iconSystemName(code: daily.weather.first?.id ?? 0))
        output.description = daily.weather.first?.description ?? R.string.dailyWeather.hyphen()
        output.date = Date(timeIntervalSince1970: Double(daily.date)).format(text: "MM/dd (EEE)")
        if let temp = daily.temp {
            output.maxTemperature = String("\(temp.max)℃")
            output.minTemperature = String("\(temp.min)℃")
        }

        self.input = input
        self.binding = binding
        self.output = output
    }
}
