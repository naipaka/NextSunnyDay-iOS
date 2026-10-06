//
//  WeatherIcon.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import SwiftUI

struct WeatherIcon {
    var image: Image
    var color: Color

    init(code: Int) {
        switch code {
        case WeatherConditionCode.clearSky.rawValue:
            image = Image(systemName: "sun.min.fill")
            color = Color(.orange)

        case WeatherConditionCode.fewClouds.rawValue,
             WeatherConditionCode.scatteredClouds.rawValue:
            image = Image(systemName: "cloud.sun.fill")
            color = Color(.orange)

        case WeatherConditionCode.brokenClouds.rawValue:
            image = Image(systemName: "cloud.fill")
            color = Color(.gray)

        case WeatherConditionCode.overcastClouds.rawValue:
            image = Image(systemName: "smoke.fill")
            color = Color(.darkGray)

        case WeatherConditionCode.lightRain.rawValue,
             WeatherConditionCode.moderateRain.rawValue,
             WeatherConditionCode.heavyIntensityRain.rawValue,
             WeatherConditionCode.veryHeavyRain.rawValue,
             WeatherConditionCode.extremeRain.rawValue:
            image = Image(systemName: "cloud.sun.rain.fill")
            color = Color(ColorResource.blue)  // the "Blue" asset, not UIColor.blue

        case WeatherConditionCode.freezingRain.rawValue,
             WeatherConditionCode.lightSnow.rawValue,
             WeatherConditionCode.snow.rawValue,
             WeatherConditionCode.heavySnow.rawValue,
             WeatherConditionCode.sleet.rawValue,
             WeatherConditionCode.lightShowerSleet.rawValue,
             WeatherConditionCode.showerSleet.rawValue,
             WeatherConditionCode.lightRainAndSnow.rawValue,
             WeatherConditionCode.rainAndSnow.rawValue,
             WeatherConditionCode.lightShowerSnow.rawValue,
             WeatherConditionCode.showerSnow.rawValue,
             WeatherConditionCode.heavyShowerSnow.rawValue:
            image = Image(systemName: "cloud.snow.fill")
            color = Color(.lightBlue)

        case WeatherConditionCode.lightIntensityDrizzle.rawValue,
             WeatherConditionCode.drizzle.rawValue,
             WeatherConditionCode.heavyIntensityDrizzle.rawValue,
             WeatherConditionCode.lightIntensityDrizzleRain.rawValue,
             WeatherConditionCode.drizzleRain.rawValue,
             WeatherConditionCode.heavyIntensityDrizzleRain.rawValue,
             WeatherConditionCode.showerRainAndDrizzle.rawValue,
             WeatherConditionCode.heavyShowerRainAndDrizzle.rawValue,
             WeatherConditionCode.showerDrizzle.rawValue,
             WeatherConditionCode.lightIntensityShowerRain.rawValue,
             WeatherConditionCode.showerRain.rawValue,
             WeatherConditionCode.heavyIntensityShowerRain.rawValue,
             WeatherConditionCode.raggedShowerRain.rawValue:
            image = Image(systemName: "cloud.heavyrain.fill")
            color = Color(.darkBlue)

        case WeatherConditionCode.thunderstormWithLightRain.rawValue,
             WeatherConditionCode.thunderstormWithRain.rawValue,
             WeatherConditionCode.thunderstormWithHeavyRain.rawValue,
             WeatherConditionCode.lightThunderstorm.rawValue,
             WeatherConditionCode.thunderstorm.rawValue,
             WeatherConditionCode.heavyThunderstorm.rawValue,
             WeatherConditionCode.raggedThunderstorm.rawValue,
             WeatherConditionCode.thunderstormWithLightDrizzle.rawValue,
             WeatherConditionCode.thunderstormWithDrizzle.rawValue,
             WeatherConditionCode.thunderstormWithHeavyDrizzle.rawValue:
            image = Image(systemName: "cloud.bolt.rain.fill")
            color = Color(.boltYellow)

        case WeatherConditionCode.mist.rawValue,
             WeatherConditionCode.smoke.rawValue,
             WeatherConditionCode.haze.rawValue,
             WeatherConditionCode.sandAmdDustWhirls.rawValue,
             WeatherConditionCode.fog.rawValue,
             WeatherConditionCode.sand.rawValue,
             WeatherConditionCode.dust.rawValue,
             WeatherConditionCode.volcanicAsh.rawValue,
             WeatherConditionCode.squalls.rawValue,
             WeatherConditionCode.tornado.rawValue:
            image = Image(systemName: "tornado")
            color = Color(.brown)

        default:
            image = Image(systemName: "questionmark.circle.fill")
            color = Color(.black)
        }
    }
}
