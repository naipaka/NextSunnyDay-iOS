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
    LegacyRealmCleanup.run()
    UINavigationBar.appearance().tintColor = .secondaryLabel
  }

  var body: some Scene {
    WindowGroup {
      let viewModel = HomeViewModel(weatherProvider: WeatherKitProvider())
      HomeView(viewModel: viewModel)
    }
  }
}
