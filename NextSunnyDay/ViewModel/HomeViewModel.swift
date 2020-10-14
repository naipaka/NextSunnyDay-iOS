//
//  HomeViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/12.
//

import Combine

// MARK: - HomeViewModelObject
protocol HomeViewModelObject: ViewModelObject where Input: HomeViewModelInputObject, Binding: HomeViewModelBindingObject, Output: HomeViewModelOutputObject {
    var input: Input { get }
    var binding: Binding { get }
    var output: Output { get }
}

// MARK: - HomeViewModelInputObject
protocol HomeViewModelInputObject: InputObject {
}

// MARK: - HomeViewModelBindingObject
protocol HomeViewModelBindingObject: BindingObject {
}

// MARK: - HomeViewModelOutputObject
protocol HomeViewModelOutputObject: OutputObject {
    var forecast: DailyWeatherForecastEntity { get }
}

// MARK: - HomeViewModel
class HomeViewModel: HomeViewModelObject {
    final class Input: HomeViewModelInputObject {}

    final class Binding: HomeViewModelBindingObject {}

    final class Output: HomeViewModelOutputObject {
        @Published var forecast = DailyWeatherForecastEntity()
    }

    var input: Input

    var binding: Binding

    var output: Output

    init() {
        let input = Input()
        let binding = Binding()
        let output = Output()

        self.input = input
        self.binding = binding
        self.output = output
    }
}
