//
//  HomeView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import SwiftUI

struct HomeView<T>: View where T: HomeViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                if viewModel.output.forecast.daily.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        VStack {
                            Spacer().frame(height: 12)
                            nextSunnyDayView
                            // TODO: Add WeeklyForecastView
                        }
                    }
                }
            }
            .navigationBarTitle(R.string.home.navigationBarTitle())
            .navigationBarItems(trailing: toSettingViewButton)
        }
    }
}

private extension HomeView {
    var toSettingViewButton: some View {
        Button(action: {}, label: {
            Image(systemName: R.string.systemName.gearshapeFill())
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .foregroundColor(.gray)
        })
    }

    var emptyView: some View {
        VStack {
            Image(systemName: R.string.systemName.sunMinFill())
                .resizable()
                .frame(width: 160, height: 160, alignment: .center)
                .padding()
            Text(R.string.home.emptyText())
            Spacer().frame(height: 60)
        }
        .foregroundColor(.gray)
    }

    var nextSunnyDayView: some View {
        HStack {
            Spacer()
                .frame(maxWidth: 18)
            NextSunnyDayMediumView(viewModel: NextSunnyDayViewModel(viewModel.output.forecast))
            Spacer()
                .frame(maxWidth: 18)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(viewModel: MockViewModel())
            HomeView(viewModel: MockViewModel(forecast: mockEntity()))
        }
    }
}

extension HomeView_Previews {
    final class MockViewModel: HomeViewModelObject {
        final class Input: HomeViewModelInputObject {}

        final class Binding: HomeViewModelBindingObject {}

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
        let mockEntity = DailyWeatherForecastEntity()
        let daily = Daily()
        let temp = Temp()
        let feelsLike = FeelsLike()
        let weather = Weather()

        temp.min = 2.0
        temp.max = 11.0
        weather.id = 800
        daily.date = 1_608_606_000
        daily.temp = temp
        daily.feelsLike = feelsLike
        daily.weather.append(weather)
        mockEntity.cityName = "東京都港区"
        mockEntity.daily.append(daily)

        return mockEntity
    }
}
