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
protocol HomeViewModelObject: ViewModelObject
where
  Input: HomeViewModelInputObject, Binding: HomeViewModelBindingObject,
  Output: HomeViewModelOutputObject
{
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
    var toSettingViewButtonTapped: PassthroughSubject<Void, Never> = PassthroughSubject<
      Void, Never
    >()
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

  private let weatherProvider: WeatherProviding
  private let results = DailyWeatherForecastEntity.all()
  private var notificationTokens: [NotificationToken] = []
  private var cancellables: [AnyCancellable] = []

  init(weatherProvider: WeatherProviding) {
    input = Input()
    binding = Binding()
    output = Output()
    output.forecast = results.first ?? DailyWeatherForecastEntity()
    self.weatherProvider = weatherProvider

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
      .sink(receiveValue: { [weak self] in self?.binding.isShowingSettingSheet.toggle() })
      .store(in: &cancellables)
  }

  deinit {
    for token in notificationTokens {
      token.invalidate()
    }
  }

  private func fetchWeatherForecast() {
    binding.isLoading = true
    let location = output.forecast.location

    Task { @MainActor in
      do {
        let forecasts = try await weatherProvider.dailyForecast(for: location)
        DailyWeatherForecastEntity.update(
          with: DailyWeatherForecastEntity(location: location, forecasts: forecasts))
      } catch {
        binding.hasError = true
      }
      binding.isLoading = false
    }
  }

  private func observeDatasource() {
    notificationTokens.append(
      self.results.observe { [weak self] change in
        guard let self = self else { return }
        switch change {
        case .initial(let results):
          let forecast = results.first ?? DailyWeatherForecastEntity()
          self.output.forecast = forecast

        case .update(let results, _, _, _):
          let forecast = results.first ?? DailyWeatherForecastEntity()
          if forecast.daily.isEmpty {
            self.output.forecast = forecast
            self.fetchWeatherForecast()
          } else {
            self.output.forecast = forecast
          }
          WidgetCenter.shared.reloadAllTimelines()

        case .error(let error):
          print(error.localizedDescription)
        }
      }
    )
  }
}
