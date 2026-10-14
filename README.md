# Next Sunny Day (次いつ晴れる？)

[日本語](README.ja.md)

<img src="docs/images/app-icon.png" width="160">

Next Sunny Day tells you when the sun comes out next, in one word: Tomorrow, or In 3 days.

Weather widgets usually show only today and tomorrow, so it was hard to tell when you could hang the laundry outside.
This app answers that question on the Home Screen, the Lock Screen and Apple Watch, with today's weather beside it.

It runs on iPhone, iPad, iPhone Duo and Apple Watch, in English and Japanese.

<a href="https://apps.apple.com/app/id1537055268"><img src="https://toolbox.marketingtools.apple.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1603584000&h=dd86e3942b5c6abc5ce1781972220b17" alt="Download on the App Store" height="60"></a>

<img src="docs/release/screenshots/iphone/en/01.jpg" width="260"><img src="docs/release/screenshots/iphone/en/02.jpg" width="260"><img src="docs/release/screenshots/iphone/en/03.jpg" width="260">

## Features

- The next sunny day, big and clear, with its weather, high and low and chance of rain
- The next 24 hours and the next 10 days
- Widgets in every Home Screen size and on the Lock Screen
- Choose what counts as sunny: clear only, sunny, up to partly cloudy, or any day without rain
- Or look for a laundry day: no rain, sunny, dry and calm from 7:00 to 19:00
- Up to three regions: your current location and any city you search for
- A notification the day before a sunny spell starts, at the time you choose
- Siri and Shortcuts: "Check Next Sunny Day"
- Apple Watch: the app and complications on the watch face
- On iPad, on iPhone in landscape and on iPhone Duo, the answer sits beside the forecast
- Forecasts from Apple Weather, no account needed

## Screenshots

### iPhone

<img src="docs/release/screenshots/iphone/en/04.jpg" width="200"><img src="docs/release/screenshots/iphone/en/05.jpg" width="200"><img src="docs/release/screenshots/iphone/en/06.jpg" width="200"><img src="docs/release/screenshots/iphone/en/07.jpg" width="200">

<img src="docs/release/screenshots/iphone/en/08.jpg" width="200"><img src="docs/release/screenshots/iphone/en/09.jpg" width="200"><img src="docs/release/screenshots/iphone/en/10.jpg" width="200">

### iPad

<img src="docs/release/screenshots/ipad/en/01.jpg" width="270"><img src="docs/release/screenshots/ipad/en/02.jpg" width="270"><img src="docs/release/screenshots/ipad/en/03.jpg" width="270">

<img src="docs/release/screenshots/ipad/en/04.jpg" width="270"><img src="docs/release/screenshots/ipad/en/05.jpg" width="270"><img src="docs/release/screenshots/ipad/en/06.jpg" width="270">

<img src="docs/release/screenshots/ipad/en/07.jpg" width="270"><img src="docs/release/screenshots/ipad/en/08.jpg" width="270"><img src="docs/release/screenshots/ipad/en/09.jpg" width="270">

### iPhone Duo

<img src="docs/release/screenshots/duo-inner/en/01.jpg" width="270"><img src="docs/release/screenshots/duo-inner/en/02.jpg" width="270"><img src="docs/release/screenshots/duo-inner/en/03.jpg" width="270">

<img src="docs/release/screenshots/duo-inner/en/04.jpg" width="270"><img src="docs/release/screenshots/duo-inner/en/05.jpg" width="270">

### Apple Watch

<img src="docs/release/screenshots/watch/en/01.jpg" width="200"><img src="docs/release/screenshots/watch/en/02.jpg" width="200"><img src="docs/release/screenshots/watch/en/03.jpg" width="200">

## Development

### Environment

| Tool | Version |
| --- | --- |
| Xcode | 27.1 |
| Swift | 6.4 (Swift 6 language mode) |
| iOS / iPadOS | 26.0 or later |
| watchOS | 26.0 or later |

### Configuration

| Area | What it uses |
| --- | --- |
| UI | SwiftUI (Liquid Glass) |
| Widget | WidgetKit (Home Screen and Lock Screen) |
| Apple Watch | A watch app and complications (WidgetKit), settings from the iPhone with WatchConnectivity |
| Weather data | WeatherKit |
| Place search | MapKit |
| Notifications | UserNotifications (local notifications) |
| Siri and Shortcuts | App Intents (App Shortcuts) |
| Modules | Local Swift packages, one per module |
| State | Observation (`@Observable` state holders in the environment) |
| Concurrency | Swift 6, Approachable Concurrency |
| Local storage | App Group `UserDefaults` + JSON files |
| Tests | Swift Testing |
| Dependencies | None (Apple frameworks only) |
| Branching | `main`, changed through pull requests |

The architecture decisions and their reasons are in [`docs/architecture/decisions/`](docs/architecture/decisions/).

### How it works

The app keeps the saved regions and the settings in `UserDefaults`, and each region's fetched forecast as a JSON file, both in an App Group container that the widget also reads.
A forecast counts as fresh when it was fetched since the last 4:00, by the app or the widget. The app fetches when it opens and the forecast isn't fresh, and on pull to refresh.
The widget shows the saved forecast. It reloads once a day after 4:00 and fetches from WeatherKit on its own when the saved forecast isn't fresh.
The Apple Watch gets the regions and settings from the iPhone and fetches its own forecast with the same rules.
[`docs/architecture/weather-fetch-flow.md`](docs/architecture/weather-fetch-flow.md) has the details.

### Directory Structure

```
NextSunnyDay/               # The app
├── App/                    # App entry, AppFeatures, PreviewHost
├── SharedState/            # @Observable state holders shared by the screens
├── Home/  DayDetail/  Onboarding/  Region/  Settings/
├── Components/
├── Resources/              # String Catalogs (.xcstrings)
└── Assets.xcassets
NextSunnyDayWidget/         # The widget extension, also compiled into the watch's complications
NextSunnyDayWatch/          # The Apple Watch app
NextSunnyDayWatchWidget/    # The watch's complications: what differs from the iPhone widget
NextSunnyDayTests/          # Tests of the app layer
Packages/
├── Core/                   # Weather, Location, PlaceSearch, Notifications, AppGroup, WatchSync
└── Features/               # Region, Forecast, SunnyDay, Notice, Units
Tools/ImportCheck/          # CI check that every import is a declared dependency
docs/                       # Design spec, architecture docs and ADRs
```

## Set up

### Clone the project

```sh
$ git clone git@github.com:naipaka/NextSunnyDay-iOS.git
$ cd NextSunnyDay-iOS
```

### Weather data

Forecasts come from [WeatherKit](https://developer.apple.com/weatherkit/). No API key is needed to build.
To fetch real forecasts, the App IDs of the app, the widget, the watch app and the watch's complications need the WeatherKit capability, and the team needs the WeatherKit App Service, both enabled in Certificates, Identifiers & Profiles. If you build with your own team, change the bundle identifiers and enable them for your App IDs.

### Formatting

Code is formatted and linted with the `swift-format` bundled with Xcode, using `.swift-format`. CI fails on lint warnings.

```sh
$ xcrun swift-format format -i -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayWatch NextSunnyDayWatchWidget NextSunnyDayTests Packages Tools
$ xcrun swift-format lint --strict -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayWatch NextSunnyDayWatchWidget NextSunnyDayTests Packages Tools
```

### Build and test

Open `NextSunnyDay.xcodeproj` in Xcode, then build and run the app. The app's tests run in the `NextSunnyDay` scheme; each package also tests on its own on the Mac:

```sh
$ for p in Packages/Core/* Packages/Features/* Tools/ImportCheck; do (cd "$p" && swift test); done
```
