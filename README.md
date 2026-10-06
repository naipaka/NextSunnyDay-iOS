# Next Sunny Day (次いつ晴れる？)

[日本語](README.ja.md)

<img src="https://user-images.githubusercontent.com/45661924/97105071-d28d2580-16fb-11eb-8f8d-7ec79940db41.png" width="300">

<img src="https://user-images.githubusercontent.com/45661924/97104876-7544a480-16fa-11eb-9bad-e1334d5ab2f8.png" height="300">

An iOS widget that shows the next sunny day on your home screen.
Weather widgets usually show only today and tomorrow, so it was hard to tell when you could hang your laundry outside.
The app also shows the weekly forecast for today through seven days later.
The app is available in Japanese only.

<a href="https://apps.apple.com/app/id1537055268" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1603584000&h=dd86e3942b5c6abc5ce1781972220b17" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Development

### Environment

| Tool  | Version          |
| ----- | ---------------- |
| Xcode | 12.0.1 (12A7300) |
| Swift | 5.3              |
| Mint  | 0.14.2           |

### Configuration

| Configuration     | Model        |
| ----------------- | ------------ |
| UI implementation | SwiftUI      |
| Widget            | WidgetKit    |
| Architecture      | MVVM+Combine |
| Local storage     | Realm        |
| Branching model   | Git-flow     |

### How it works

The app saves the forecast for the place you choose to Realm, in an App Group container that the widget can also read.
The widget shows the saved forecast and refreshes every five hours. When the saved forecast is out of date, the widget fetches a new one from the OpenWeather API on its own.
Places are searched with MapKit's `MKLocalSearchCompleter`.

### Directory Structure

```
NextSunnyDay/
├── NextSunnyDayApp.swift
├── API/
│   ├── AccessTokens.swift   # Created in Set up, not committed
│   ├── OpenWeatherAPI/
│   └── LocalSearch/
├── Model/
├── View/
├── ViewModel/
├── Protocol/
├── Extension/
├── UIViewRepresentable/
├── Resourece/
│   └── strings/
├── Settings.bundle
├── Assets.xcassets
├── Info.plist
└── Preview Content/
    └── Preview Assets.xcassets
NextSunnyDayWidget/
└── NextSunnyDayWidget.swift
```

## Set up

### Clone the project

```sh
$ git clone git@github.com:naipaka/NextSunnyDay-iOS.git
$ cd NextSunnyDay-iOS
```

### API key

This app uses the OpenWeather API. Get an API key from the following page.

[How to start to work with Openweather API - OpenWeatherMap](https://openweathermap.org/appid)

Then run the following command in the root directory to create `NextSunnyDay/API/AccessTokens.swift`.

```sh
$ echo "let openWeatherAPIKey = \"{YOUR_API_KEY}\"" > ./NextSunnyDay/API/AccessTokens.swift
```

### Mint

Install [Mint](https://github.com/yonaskolb/Mint) first, then install the tools in the `Mintfile` (SwiftLint, R.swift, and LicensePlist). The build phases use them.

```sh
$ mint bootstrap
```

### Build

Open `NextSunnyDay.xcodeproj` in Xcode, then build and run the app.

## Screenshots

| Screen         | Light                                                                                                                        | Dark                                                                                                                         |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Widget         | <img src="https://user-images.githubusercontent.com/45661924/97104984-4f6bcf80-16fb-11eb-8e4f-13f0b694cd4b.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105017-8e018a00-16fb-11eb-92ad-20fd0c67c0e0.png" width="300"> |
| Home           | <img src="https://user-images.githubusercontent.com/45661924/97104990-54c91a00-16fb-11eb-9408-40ac76eb52ea.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105024-98bc1f00-16fb-11eb-8149-fbffd415dd3e.png" width="300"> |
| Setting        | <img src="https://user-images.githubusercontent.com/45661924/97104994-585ca100-16fb-11eb-9bcb-c57bc9009f55.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105027-9c4fa600-16fb-11eb-9d8c-41614202eddb.png" width="300"> |
| Region Search  | <img src="https://user-images.githubusercontent.com/45661924/97105000-66122680-16fb-11eb-9286-2bf512212082.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105031-9fe32d00-16fb-11eb-841f-8b9753442253.png" width="300"> |
| Search results | <img src="https://user-images.githubusercontent.com/45661924/97105005-6d393480-16fb-11eb-8be8-06fbf7204ec0.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105039-a671a480-16fb-11eb-873b-77fec5736546.png" width="300"> |
| About weather  | <img src="https://user-images.githubusercontent.com/45661924/97105009-7fb36e00-16fb-11eb-849e-a4b6c5bffdb8.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105042-aa052b80-16fb-11eb-9feb-f18031116f02.png" width="300"> |
