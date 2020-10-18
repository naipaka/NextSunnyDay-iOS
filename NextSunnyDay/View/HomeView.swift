//
//  HomeView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import Combine
import SwiftUI

struct HomeView<T>: View where T: HomeViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
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
                                Spacer().frame(height: 36)
                                dailyWeatherView
                            }
                        }
                    }
                }
                .navigationBarTitle(R.string.home.navigationBarTitle())
                .navigationBarItems(trailing: toSettingViewButton)
            }
            if viewModel.binding.isLoading {
                LoadingView()
            }
        }
    }
}

private extension HomeView {
    var toSettingViewButton: some View {
        Button(
            action: {
                viewModel.input.toSettingViewButtonTapped.send()
            },
            label: {
                Image(systemName: R.string.systemName.gearshapeFill())
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor(.gray)
            }
        )
        .sheet(isPresented: $viewModel.binding.isShowingSettingSheet) {
            SettingView(viewModel: SettingViewModel(viewModel.output.forecast))
        }
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

    var dailyWeatherView: some View {
        HStack {
            Spacer()
                .frame(maxWidth: 18)
            VStack(alignment: .leading) {
                Text(R.string.home.weeklyWeather())
                    .font(.system(size: 24))
                    .bold()
                ForEach(viewModel.output.forecast.daily) {
                    DailyWeatherView(viewModel: DailyWeatherViewModel($0))
                        .frame(height: 82)
                }
                Spacer()
            }
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
        final class Input: HomeViewModelInputObject {
            var toSettingViewButtonTapped = PassthroughSubject<Void, Never>()
        }

        final class Binding: HomeViewModelBindingObject {
            @Published var isShowingSettingSheet: Bool = false
            @Published var isLoading: Bool = false
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
        let mockEntity = DailyWeatherForecastEntity()
        mockEntity.cityName = "東京都港区"
        mockEntity.daily.append(mockDaily(date: 1_608_433_200, code: 300, description: "雨"))
        mockEntity.daily.append(mockDaily(date: 1_608_519_600, code: 500, description: "天気雨"))
        mockEntity.daily.append(mockDaily(date: 1_608_606_000, code: 800, description: "快晴"))
        mockEntity.daily.append(mockDaily(date: 1_608_692_400, code: 803, description: "曇り"))
        mockEntity.daily.append(mockDaily(date: 1_608_778_800, code: 801, description: "晴れ"))
        mockEntity.daily.append(mockDaily(date: 1_608_865_200, code: 511, description: "雪"))
        mockEntity.daily.append(mockDaily(date: 1_608_951_600, code: 804, description: "暑い雲"))
        mockEntity.daily.append(mockDaily(date: 1_609_038_000, code: 200, description: "雷雨"))
        return mockEntity
    }

    private static func mockDaily(date: Int, code: Int, description: String) -> Daily {
        let daily = Daily()
        let temp = Temp()
        let weather = Weather()

        temp.min = 2.0
        temp.max = 11.0
        weather.id = code
        weather.weatherDescription = description
        daily.date = date
        daily.temp = temp
        daily.weather.append(weather)
        return daily
    }
}
