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
                Text(R.string.aboutWeatherForecast.infoSource())
                    .padding()
                Text(R.string.aboutWeatherForecast.termsOfUse())
                    .padding()
                Button(
                    action: {
                        if let url = openWeatherURL {
                            UIApplication.shared.open(url)
                        }
                    },
                    label: {
                        Text(R.string.aboutWeatherForecast.openWeatherSWebsite())
                    }
                )
                .padding()
                Spacer()
            }
        }
        .font(.none)
        .navigationBarTitle(R.string.aboutWeatherForecast.aboutWeatherForecast())
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
