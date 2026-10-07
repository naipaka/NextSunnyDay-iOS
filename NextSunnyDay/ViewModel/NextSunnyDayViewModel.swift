//
//  NextSunnyDayViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/13.
//

import Combine
import Foundation
import SwiftUI

// MARK: - NextSunnyDayViewModelObject
protocol NextSunnyDayViewModelObject: ViewModelObject
where
  Input: NextSunnyDayViewModelInputObject, Binding: NextSunnyDayViewModelBindingObject,
  Output: NextSunnyDayViewModelOutputObject
{
  var input: Input { get }
  var binding: Binding { get }
  var output: Output { get }
}

// MARK: - NextSunnyDayViewModelInputObject
protocol NextSunnyDayViewModelInputObject: InputObject {
}

// MARK: - NextSunnyDayViewModelBindingObject
protocol NextSunnyDayViewModelBindingObject: BindingObject {
}

// MARK: - NextSunnyDayViewModelOutputObject
protocol NextSunnyDayViewModelOutputObject: OutputObject {
  var backgroundColor: LinearGradient { get }
  var textColor: Color { get }
  var cityName: String { get }
  var nextSunnyDay: String { get }
  var maxTemperature: String { get }
  var minTemperature: String { get }
}

// MARK: - NextSunnyDayViewModel
class NextSunnyDayViewModel: NextSunnyDayViewModelObject {
  final class Input: NextSunnyDayViewModelInputObject {}

  final class Binding: NextSunnyDayViewModelBindingObject {}

  final class Output: NextSunnyDayViewModelOutputObject {
    @Published var backgroundColor: LinearGradient = .noNextSunnyDayBackground
    @Published var textColor: Color = .white
    @Published var cityName = ""
    @Published var nextSunnyDay = String(localized: "Next Week or Later")
    @Published var maxTemperature = "-"
    @Published var minTemperature = "-"
  }

  var input: Input

  var binding: Binding

  var output: Output

  init(_ forecast: ForecastSnapshot?) {
    let input = Input()
    let binding = Binding()
    let output = Output()

    // output
    output.cityName = forecast?.location.name ?? ""
    if let nextSunnyDay = forecast?.daily.nextSunnyDay {
      output.backgroundColor = .nextSunnyDayBackground
      output.textColor = Color(.nextSunnyDayText)
      output.nextSunnyDay = nextSunnyDay.date.format(text: "M/d (EEE)")
      output.maxTemperature = nextSunnyDay.highTemperature.celsiusText
      output.minTemperature = nextSunnyDay.lowTemperature.celsiusText
    }

    self.input = input
    self.binding = binding
    self.output = output
  }
}
