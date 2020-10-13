//
//  NextSunnyDayViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/13.
//

import Combine
import Foundation
import RealmSwift

// MARK: - NextSunnyDayViewModelObject
protocol NextSunnyDayViewModelObject: ViewModelObject where Input: NextSunnyDayViewModelInputObject, Binding: NextSunnyDayViewModelBindingObject, Output: NextSunnyDayViewModelOutputObject {
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
        @Published var cityName = ""
        @Published var nextSunnyDay = ""
        @Published var maxTemperature = ""
        @Published var minTemperature = ""
    }

    var input: Input

    var binding: Binding

    var output: Output

    init(_ forecast: DailyWeatherForecastEntity) {
        let input = Input()
        let binding = Binding()
        let output = Output()

        // output
        if let nearestSunnyDay = forecast.daily.filter({ sunnyCodes.contains($0.weather.first?.id ?? 0) }).min(by: { $0.date < $1.date }) {
            // UNIX -> Date
            let formatter = DateFormatter()
            formatter.dateFormat = "yMMMdE"
            let nextSunnyDay = formatter.string(from: Date(timeIntervalSince1970: Double(nearestSunnyDay.date)))
            
            output.cityName = forecast.cityName
            output.nextSunnyDay = nextSunnyDay
            output.maxTemperature = String("\(nearestSunnyDay.temp?.max)")
            output.minTemperature = String("\(nearestSunnyDay.temp?.min)")
        } else {
            output.cityName = forecast.cityName
            output.nextSunnyDay = R.string.nextSunnyDay.nextWeekOnwards()
            output.maxTemperature = R.string.nextSunnyDay.hyphen()
            output.minTemperature = R.string.nextSunnyDay.hyphen()
        }

        self.input = input
        self.binding = binding
        self.output = output
    }
}
