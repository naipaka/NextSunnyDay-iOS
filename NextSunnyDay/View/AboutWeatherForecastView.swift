//
//  AboutWeatherForecastView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/22.
//

import SwiftUI

struct AboutWeatherForecastView: View {
  var body: some View {
    ZStack {
      Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
      VStack(alignment: .leading) {
        Text("This app shows information based on weather forecasts from OpenWeather.")
          .padding()
        Text(
          "We accept no responsibility for any loss or damage caused by the weather forecast information in this app."
        )
        .padding()
        Button(
          action: {
            if let url = openWeatherURL {
              UIApplication.shared.open(url)
            }
          },
          label: {
            Text("OpenWeather Website")
              .foregroundColor(.secondary)
              .underline()
          }
        )
        .padding()
        Spacer()
      }
    }
    .font(.none)
    .navigationBarTitle("About Weather Forecast")
  }
}

extension AboutWeatherForecastView {
  private var openWeatherURL: URL? {
    let urlString = "https://openweathermap.org/"
    return URL(string: urlString)
  }
}

struct AboutWeatherForecastView_Previews: PreviewProvider {
  static var previews: some View {
    AboutWeatherForecastView()
  }
}
