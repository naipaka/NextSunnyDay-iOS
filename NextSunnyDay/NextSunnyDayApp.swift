//
//  NextSunnyDayApp.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import SwiftUI

@main
struct NextSunnyDayApp: App {
    init() {
        UINavigationBar.appearance().tintColor = .secondaryLabel
    }

    var body: some Scene {
        WindowGroup {
            let weatherFecther = WeatherFetcher()
            let viewModel = HomeViewModel(weatherFetcher: weatherFecther)
            HomeView(viewModel: viewModel)
        }
    }
}
