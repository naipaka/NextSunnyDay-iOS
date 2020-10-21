//
//  DailyWeatherForecastEntity.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/09.
//

import Foundation
import RealmSwift

// MARK: - DailyWeatherForecastEntity
class DailyWeatherForecastEntity: Object, Identifiable {
    @objc dynamic var id: Int = 0
    @objc dynamic var cityName: String = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lon: Double = 0.0
    var daily = List<Daily>()

    override static func primaryKey() -> String? {
        "id"
    }
}

// MARK: - Daily
class Daily: Object, Identifiable {
    @objc dynamic var date: Int = 0
    @objc dynamic var temp: Temp?
    @objc dynamic var humidity: Int = 0
    @objc dynamic var pop: Double = 0.0
    @objc dynamic var rain: Double = 0.0
    @objc dynamic var snow: Double = 0.0
    @objc dynamic var uvi: Double = 0.0
    var weather = List<Weather>()
}

// MARK: - Temp
class Temp: Object, Identifiable {
    @objc dynamic var day: Double = 0.0
    @objc dynamic var min: Double = 0.0
    @objc dynamic var max: Double = 0.0
    @objc dynamic var night: Double = 0.0
    @objc dynamic var eve: Double = 0.0
    @objc dynamic var morn: Double = 0.0
}

// MARK: - Weather
class Weather: Object, Identifiable {
    @objc dynamic var id: Int = 0
    @objc dynamic var main: String = ""
    @objc dynamic var weatherDescription: String = ""
    @objc dynamic var icon: String = ""
}

// MARK: - CRUD
extension DailyWeatherForecastEntity {
    private static var realm: Realm {
        var config = Realm.Configuration()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.naipaka.NextSunnyDay")!
        config.fileURL = url.appendingPathComponent("db.realm")
        let realm = try! Realm(configuration: config)
        return realm
    }

    static func all() -> Results<DailyWeatherForecastEntity> {
        realm.objects(self)
    }

    static func create(with weeklyWeather: DailyWeatherForecastEntity) {
        try! realm.write {
            realm.add(weeklyWeather)
        }
    }

    static func update(with weeklyWeather: DailyWeatherForecastEntity) {
        try! realm.write {
            realm.create(DailyWeatherForecastEntity.self, value: weeklyWeather, update: .all)
        }
    }
}

extension DailyWeatherForecastEntity {
    static func generateEntity(cityName: String, forecast: DailyWeatherForecastResponse) -> DailyWeatherForecastEntity {
        // WeeklyForecastEntity
        let entity = DailyWeatherForecastEntity()
        entity.cityName = cityName
        entity.lat = forecast.lat
        entity.lon = forecast.lon

        // Daily
        forecast.daily.forEach {
            let daily = Daily()
            daily.date = $0.date
            daily.humidity = $0.humidity
            daily.pop = $0.pop
            daily.rain = $0.rain ?? 0.0
            daily.snow = $0.snow ?? 0.0
            daily.uvi = $0.uvi

            // Temp
            let temp = Temp()
            temp.day = $0.temp.day
            temp.min = $0.temp.min
            temp.max = $0.temp.max
            temp.night = $0.temp.night
            temp.eve = $0.temp.eve
            temp.morn = $0.temp.morn
            daily.temp = temp

            // Weather
            $0.weather.forEach {
                let weather = Weather()
                weather.id = $0.id
                weather.main = $0.main
                weather.weatherDescription = $0.weatherDescription
                weather.icon = $0.icon
                daily.weather.append(weather)
            }

            entity.daily.append(daily)
        }
        return entity
    }

    static func defaultEntity() -> DailyWeatherForecastEntity {
        let entity = DailyWeatherForecastEntity()
        entity.cityName = "東京駅"
        entity.lat = 35.680_959_1
        entity.lon = 139.767_306_8

        // Daily
        let daily = Daily()
        daily.date = Int(Date().timeIntervalSince1970) + 60 * 60 * 24
        daily.humidity = 0
        daily.pop = 0.0
        daily.rain = 0.0
        daily.snow = 0.0
        daily.uvi = 0.0

        // Temp
        let temp = Temp()
        temp.day = 20.0
        temp.min = 15.0
        temp.max = 20.0
        temp.night = 15.0
        temp.eve = 15.0
        temp.morn = 15.0
        daily.temp = temp

        // Weather
        let weather = Weather()
        weather.id = 800
        weather.main = "晴れ"
        weather.weatherDescription = "晴天"
        weather.icon = "01d"
        daily.weather.append(weather)

        entity.daily.append(daily)

        return entity
    }
}
