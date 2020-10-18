//
//  DailyWeatherForecastResponse.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/01.
//

import Foundation

// MARK: - DailyWeatherForecastResponse
struct DailyWeatherForecastResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case timezone
        case timezoneOffset = "timezone_offset"
        case daily
    }

    // MARK: - Daily
    struct Daily: Codable {
        let date: Int
        let sunrise: Int
        let sunset: Int
        let temp: Temp
        let feelsLike: FeelsLike
        let pressure: Int
        let humidity: Int
        let dewPoint: Double
        let windSpeed: Double
        let windGust: Double
        let windDeg: Int
        let weather: [Weather]
        let clouds: Int
        let pop: Double
        let rain: Double?
        let snow: Double?
        let uvi: Double

        enum CodingKeys: String, CodingKey {
            case date = "dt"
            case sunrise
            case sunset
            case temp
            case feelsLike = "feels_like"
            case pressure
            case humidity
            case dewPoint = "dew_point"
            case windSpeed = "wind_speed"
            case windGust = "wind_gust"
            case windDeg = "wind_deg"
            case weather
            case clouds
            case pop
            case rain
            case snow
            case uvi
        }

        // MARK: - Temp
        struct Temp: Codable {
            let day: Double
            let min: Double
            let max: Double
            let night: Double
            let eve: Double
            let morn: Double
        }

        // MARK: - FeelsLike
        struct FeelsLike: Codable {
            let day: Double
            let night: Double
            let eve: Double
            let morn: Double
        }

        // MARK: - Weather
        struct Weather: Codable {
            let id: Int
            let main: String
            let weatherDescription: String
            let icon: String

            enum CodingKeys: String, CodingKey {
                case id
                case main
                case weatherDescription = "description"
                case icon
            }
        }
    }
}
