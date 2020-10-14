//
//  WeatherConditionCode.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/13.
//

enum WeatherConditionCode: Int {
    // MARK: - Group 2xx: Thunderstorm
    case thunderstormWithLightRain = 200
    case thunderstormWithRain = 201
    case thunderstormWithHeavyRain = 202
    case lightThunderstorm = 210
    case thunderstorm = 211
    case heavyThunderstorm = 212
    case raggedThunderstorm = 221
    case thunderstormWithLightDrizzle = 230
    case thunderstormWithDrizzle = 231
    case thunderstormWithHeavyDrizzle = 232

    // MARK: - Group 3xx: Drizzle
    case lightIntensityDrizzle = 300
    case drizzle = 301
    case heavyIntensityDrizzle = 302
    case lightIntensityDrizzleRain = 310
    case drizzleRain = 311
    case heavyIntensityDrizzleRain = 312
    case showerRainAndDrizzle = 313
    case heavyShowerRainAndDrizzle = 314
    case showerDrizzle = 321

    // MARK: - Group 5xx: Rain
    case lightRain = 500
    case moderateRain = 501
    case heavyIntensityRain = 502
    case veryHeavyRain = 503
    case extremeRain = 504
    case freezingRain = 511
    case lightIntensityShowerRain = 520
    case showerRain = 521
    case heavyIntensityShowerRain = 522
    case raggedShowerRain = 531

    // MARK: - Group 6xx: Snow
    case lightSnow = 600
    case snow = 601
    case heavySnow = 602
    case sleet = 611
    case lightShowerSleet = 612
    case showerSleet = 613
    case lightRainAndSnow = 615
    case rainAndSnow = 616
    case lightShowerSnow = 620
    case showerSnow = 621
    case heavyShowerSnow = 622

    // MARK: - Group 7xx: Atmosphere
    case mist = 701
    case smoke = 711
    case haze = 721
    case sandAmdDustWhirls = 731
    case fog = 741
    case sand = 751
    case dust = 761
    case volcanicAsh = 762
    case squalls = 771
    case tornado = 781

    // MARK: - Group 800: Clear
    case clearSky = 800

    // MARK: - Group 80x: Clouds
    case fewClouds = 801
    case scatteredClouds = 802
    case brokenClouds = 803
    case overcastClouds = 804
}

extension WeatherConditionCode {
    static let sunnyCodes = [
        Self.clearSky.rawValue,
        Self.fewClouds.rawValue,
        Self.scatteredClouds.rawValue
    ]
}
