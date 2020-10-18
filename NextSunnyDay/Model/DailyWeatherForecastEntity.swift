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
    @objc dynamic var cityName: String = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lon: Double = 0.0
    var daily = List<Daily>()
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
    private static var realm = try! Realm()

    static func all() -> Results<DailyWeatherForecastEntity> {
        realm.objects(self)
    }

    static func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    static func create(with weeklyWeather: DailyWeatherForecastEntity) {
        try! realm.write {
            realm.add(weeklyWeather)
        }
    }
}
