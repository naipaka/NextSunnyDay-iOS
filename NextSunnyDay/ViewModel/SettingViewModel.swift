//
//  SettingViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import Combine
import Foundation

// MARK: - SettingViewModelObject
protocol SettingViewModelObject: ViewModelObject where Input: SettingViewModelInputObject, Binding: SettingViewModelBindingObject, Output: SettingViewModelOutputObject {
    var input: Input { get }
    var binding: Binding { get }
    var output: Output { get }
}

// MARK: - SettingViewModelInputObject
protocol SettingViewModelInputObject: InputObject {
}

// MARK: - SettingViewModelBindingObject
protocol SettingViewModelBindingObject: BindingObject {
}

// MARK: - SettingViewModelOutputObject
protocol SettingViewModelOutputObject: OutputObject {
    var cityName: String { get }
    var version: String { get }
    var reviewURL: URL? { get }
    var contactUsPageURL: URL? { get }
}

// MARK: - SettingViewModel
class SettingViewModel: SettingViewModelObject {
    final class Input: SettingViewModelInputObject {}

    final class Binding: SettingViewModelBindingObject {}

    final class Output: SettingViewModelOutputObject {
        @Published var cityName: String = R.string.setting.unset()
        @Published var version: String = R.string.setting.hyphen()
        @Published var reviewURL: URL?
        @Published var contactUsPageURL: URL?
    }

    var input: Input

    var binding: Binding

    var output: Output

    init(_ forecast: DailyWeatherForecastEntity) {
        let input = Input()
        let binding = Binding()
        let output = Output()

        // output
        if forecast.cityName != "" {
            output.cityName = forecast.cityName
        }
        output.version = Bundle.main.object(forInfoDictionaryKey: R.string.setting.cfBundleShortVersionString()) as? String ?? R.string.setting.hyphen()
        // TODO: set review url
        output.reviewURL = nil
        output.contactUsPageURL = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdOw2aW3VP6OYI1jNO4xZtDmkKzJ33otOQLmBxhcKQejuniAQ/viewform?usp=sf_link")

        self.input = input
        self.binding = binding
        self.output = output
    }
}
