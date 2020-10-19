//
//  NextSunnyDayApp.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import SwiftUI

@main
struct NextSunnyDayApp: App {
    var body: some Scene {
        WindowGroup {
            let weatherFecther = WeatherFetcher()
            let viewModel = HomeViewModel(weatherFetcher: weatherFecther)
            HomeView(viewModel: viewModel)
        }
    }
}
