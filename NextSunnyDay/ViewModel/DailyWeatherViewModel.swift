//
//  DailyWeatherViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import Combine
import Foundation
import SwiftUI

// MARK: - DailyWeatherViewModelObject
protocol DailyWeatherViewModelObject: ViewModelObject
where
  Input: DailyWeatherViewModelInputObject, Binding: DailyWeatherViewModelBindingObject,
  Output: DailyWeatherViewModelOutputObject
{
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
  var icon: WeatherIcon { get }
  var weatherDescription: String { get }
  var date: String { get }
  var maxTemperature: String { get }
  var minTemperature: String { get }
}

// MARK: - DailyWeatherViewModel
class DailyWeatherViewModel: DailyWeatherViewModelObject {
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

  init(_ forecast: DailyForecast) {
    let input = Input()
    let binding = Binding()
    let output = Output()

    // output
    output.icon = WeatherIcon(forecast)
    output.weatherDescription = forecast.condition.description
    output.date = forecast.date.format(text: "M/d (EEE)")
    output.maxTemperature = forecast.highTemperature.celsiusText
    output.minTemperature = forecast.lowTemperature.celsiusText

    self.input = input
    self.binding = binding
    self.output = output
  }
}
