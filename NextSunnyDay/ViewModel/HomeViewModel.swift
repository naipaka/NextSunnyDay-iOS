//
//  HomeViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/12.
//

import Combine
import Foundation
import RealmSwift
import WidgetKit

// MARK: - HomeViewModelObject
protocol HomeViewModelObject: ViewModelObject where Input: HomeViewModelInputObject, Binding: HomeViewModelBindingObject, Output: HomeViewModelOutputObject {
    var input: Input { get }
    var binding: Binding { get set }
    var output: Output { get }
}

// MARK: - HomeViewModelInputObject
protocol HomeViewModelInputObject: InputObject {
    var toSettingViewButtonTapped: PassthroughSubject<Void, Never> { get }
}

// MARK: - HomeViewModelBindingObject
protocol HomeViewModelBindingObject: BindingObject {
    var isShowingSettingSheet: Bool { get set }
    var isLoading: Bool { get set }
    var hasError: Bool { get set }
}

// MARK: - HomeViewModelOutputObject
protocol HomeViewModelOutputObject: OutputObject {
    var forecast: DailyWeatherForecastEntity { get }
}

// MARK: - HomeViewModel
class HomeViewModel: HomeViewModelObject {
    final class Input: HomeViewModelInputObject {
        var toSettingViewButtonTapped: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    }

    final class Binding: HomeViewModelBindingObject {
        @Published var isShowingSettingSheet: Bool = false
        @Published var isLoading: Bool = false
        @Published var hasError = false
    }

    final class Output: HomeViewModelOutputObject {
        @Published var forecast = DailyWeatherForecastEntity()
    }

    var input: Input

    var binding: Binding

    var output: Output

    private let weatherFetcher: WeatherFetchable
    private let results = DailyWeatherForecastEntity.all()
    private var notificationTokens: [NotificationToken] = []
    private var cancellables: [AnyCancellable] = []

    init(weatherFetcher: WeatherFetchable) {
        input = Input()
        binding = Binding()
        output = Output()
        output.forecast = results.first ?? DailyWeatherForecastEntity()
        self.weatherFetcher = weatherFetcher

        observeDatasource()

        if !output.forecast.cityName.isEmpty {
            let now = Int(Date().timeIntervalSince1970)
            let latestForecast = output.forecast.daily.min(by: { $0.date < $1.date })

            if (latestForecast?.date ?? 0) + 60 * 60 * 24 < now {
                fetchWeatherForecast()
            }
        }

        // input
        input.toSettingViewButtonTapped
            .sink( receiveValue: { [weak self] in self?.binding.isShowingSettingSheet.toggle() })
            .store(in: &cancellables)
    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }

    private func fetchWeatherForecast() {
        binding.isLoading = true

        // Weather Fetcher
        weatherFetcher.weeklyWeatherForecast(forLat: output.forecast.lat, forLon: output.forecast.lon)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }

                    switch value {
                    case .failure:
                        self.binding.hasError.toggle()

                    case .finished:
                        break
                    }

                    self.binding.isLoading = false
                },
                receiveValue: { [weak self] forecast in
                    guard let self = self else { return }
                    DailyWeatherForecastEntity.update(with: DailyWeatherForecastEntity.generateEntity(cityName: self.output.forecast.cityName, forecast: forecast))
                    self.binding.isLoading = false
                }
            )
            .store(in: &cancellables)
    }

    private func observeDatasource() {
        notificationTokens.append(
            self.results.observe { [weak self] change in
                guard let self = self else { return }
                switch change {
                case let .initial(results):
                    guard let forecast = results.first ?? DailyWeatherForecastEntity() else { return }
                    self.output.forecast = forecast

                case let .update(results, _, _, _):
                    guard let forecast = results.first ?? DailyWeatherForecastEntity() else { return }
                    if forecast.daily.isEmpty {
                        self.output.forecast = forecast
                        self.fetchWeatherForecast()
                    } else {
                        self.output.forecast = forecast
                    }
                    WidgetCenter.shared.reloadAllTimelines()

                case let .error(error):
                    print(error.localizedDescription)
                }
            }
        )
    }
}
