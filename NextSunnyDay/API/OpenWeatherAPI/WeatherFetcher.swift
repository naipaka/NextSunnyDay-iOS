//
//  WeatherFetcher.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/01.
//

import Combine
import Foundation

protocol WeatherFetchable {
    func weeklyWeatherForecast(
        forLat lat: Double, forLon lon: Double
    ) -> AnyPublisher<DailyWeatherForecastResponse, WeatherError>
}

class WeatherFetcher {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - OpenWeatherMap API
private extension WeatherFetcher {
    enum OpenWeatherAPI {
        static let scheme = "https"
        static let host = "api.openweathermap.org"
        static let path = "/data/2.5"
        static let key = OPEN_WEATHER_API_KEY
    }

    func makeWeeklyForecastComponents(
        withLat lat: Double, withLon lon: Double
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = OpenWeatherAPI.scheme
        components.host = OpenWeatherAPI.host
        components.path = OpenWeatherAPI.path + "/onecall"

        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "exclude", value: "current,minutely,hourly,alerts"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ja"),
            URLQueryItem(name: "appid", value: OpenWeatherAPI.key)
        ]

        return components
    }

    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, WeatherError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                .parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - WeatherFetchable
extension WeatherFetcher: WeatherFetchable {
    func weeklyWeatherForecast(
        forLat lat: Double, forLon lon: Double
    ) -> AnyPublisher<DailyWeatherForecastResponse, WeatherError> {
        forecast(with: makeWeeklyForecastComponents(withLat: lat, withLon: lon))
    }

    private func forecast<T>(
        with components: URLComponents
    ) -> AnyPublisher<T, WeatherError> where T: Decodable {
        guard let url = components.url else {
            let error = WeatherError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                .network(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                self.decode(pair.data)
            }
            .eraseToAnyPublisher()
    }
}
