//
//  HomeView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import Combine
import SwiftUI
import WeatherKit

struct HomeView<T>: View where T: HomeViewModelObject {
  @ObservedObject private var viewModel: T

  init(viewModel: T) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      NavigationView {
        ZStack {
          Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
          if viewModel.output.forecast.daily.isEmpty {
            emptyView
          } else {
            ScrollView {
              VStack {
                Spacer().frame(height: 12)
                nextSunnyDayView
                Spacer().frame(height: 36)
                dailyWeatherView
              }
            }
          }
          if viewModel.binding.hasError {
            errorView
          }
        }
        .navigationBarTitle("Next Sunny Day ☀️")
        .navigationBarItems(trailing: toSettingViewButton)
      }
      if viewModel.binding.isLoading {
        LoadingView()
      }
    }
  }
}

extension HomeView {
  fileprivate var toSettingViewButton: some View {
    Button(
      action: {
        viewModel.input.toSettingViewButtonTapped.send()
      },
      label: {
        Image(systemName: "gearshape.fill")
          .resizable()
          .frame(width: 20, height: 20, alignment: .center)
          .foregroundColor(.gray)
      }
    )
    .sheet(isPresented: $viewModel.binding.isShowingSettingSheet) {
      SettingView(viewModel: SettingViewModel(viewModel.output.forecast))
    }
  }

  fileprivate var emptyView: some View {
    VStack {
      Image(systemName: "sun.min.fill")
        .resizable()
        .frame(width: 160, height: 160, alignment: .center)
        .padding()
      Text("Set your region with the\nsettings button at the top right")
      Spacer().frame(height: 60)
    }
    .foregroundColor(.gray)
  }

  fileprivate var nextSunnyDayView: some View {
    HStack {
      Spacer()
        .frame(maxWidth: 18)
      NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(viewModel.output.forecast))
        .cornerRadius(20)
      Spacer()
        .frame(maxWidth: 18)
    }
  }

  fileprivate var dailyWeatherView: some View {
    HStack {
      Spacer()
        .frame(maxWidth: 18)
      VStack(alignment: .leading) {
        Text("10-Day Forecast")
          .font(.system(size: 24))
          .bold()
        ForEach(viewModel.output.forecast.dailyForecasts, id: \.date) {
          DailyWeatherView(viewModel: DailyWeatherViewModel($0))
            .frame(height: 82)
        }
        Spacer()
      }
      Spacer()
        .frame(maxWidth: 18)
    }
  }

  fileprivate var errorView: some View {
    VStack {
      ZStack {
        VStack {
          Spacer().frame(height: 20)
          Text("Data Fetching Error")
            .font(.title3)
          Text("Failed to fetch weather data.\nPlease wait a while and restart the app.")
            .padding()
        }
        HStack {
          Spacer()
          VStack {
            Button(
              action: {
                viewModel.binding.hasError.toggle()
              },
              label: {
                Image(systemName: "xmark")
                  .resizable()
                  .frame(width: 14, height: 14, alignment: .center)
                  .foregroundColor(Color(.systemGray))
              }
            )
            .padding()
            Spacer()
          }
        }
      }
      .background(Color(.systemBackground))
      .cornerRadius(20)
      .padding()
      .fixedSize()
      Spacer()
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HomeView(viewModel: MockViewModel())
      HomeView(viewModel: MockViewModel(forecast: mockEntity()))
      HomeView(viewModel: MockViewModel())
        .environment(\.colorScheme, .dark)
      HomeView(viewModel: MockViewModel(forecast: mockEntity()))
        .environment(\.colorScheme, .dark)
    }
  }
}

extension HomeView_Previews {
  final class MockViewModel: HomeViewModelObject {
    final class Input: HomeViewModelInputObject {
      var toSettingViewButtonTapped = PassthroughSubject<Void, Never>()
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

    init(forecast: DailyWeatherForecastEntity = DailyWeatherForecastEntity()) {
      let input = Input()
      let binding = Binding()
      let output = Output()

      output.forecast = forecast

      self.input = input
      self.binding = binding
      self.output = output
    }
  }

  private static func mockEntity() -> DailyWeatherForecastEntity {
    let day: TimeInterval = 60 * 60 * 24
    let start = Date()
    let conditions: [(WeatherCondition, String)] = [
      (.drizzle, "cloud.drizzle"), (.rain, "cloud.rain"), (.clear, "sun.max"),
      (.mostlyCloudy, "cloud.sun"), (.mostlyClear, "sun.min"), (.snow, "cloud.snow"),
      (.cloudy, "cloud"), (.thunderstorms, "cloud.bolt.rain"),
    ]
    return DailyWeatherForecastEntity(
      location: ForecastLocation(name: "東京都港区", latitude: 35.658, longitude: 139.751),
      forecasts: conditions.enumerated().map { offset, sample in
        .sample(
          date: start.addingTimeInterval(day * Double(offset)), condition: sample.0,
          symbolName: sample.1)
      }
    )
  }
}
