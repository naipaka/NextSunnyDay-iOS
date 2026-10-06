# Weather Forecast Fetch Flow

The forecast is stored in Realm (`DailyWeatherForecastEntity`) inside the App Group container, so the app and the widget read the same data. Views never read the API response directly: every fetch writes to Realm, and the UI updates from the Realm change notification.

Forecasts come from WeatherKit through `WeatherProviding` (`WeatherKitProvider`), which returns the 10-day daily forecast as `[DailyForecast]`. The Realm bridge (`DailyWeatherForecastEntity+DailyForecast.swift`) converts it into the entity before saving, and back into `[DailyForecast]` for the views. A failed fetch leaves the stored forecast as is.

## App launch

`HomeViewModel.init` decides whether the stored forecast is stale.

```mermaid
flowchart TD
    A([App launch]) --> B[Load forecast from Realm]
    B --> C{cityName is empty?}
    C -- Yes --> D[Show empty view<br/>prompting region setup]
    C -- No --> E{Oldest daily entry is<br/>more than 24h old?}
    E -- No --> H[Show home screen]
    E -- Yes --> F[Show loading indicator<br/>and fetch the daily forecast from WeatherKit]
    F --> G[Save forecast to Realm]
    G --> G2[Realm change notification<br/>updates output.forecast]
    G2 --> G3[Hide loading indicator<br/>and reload widget timelines]
    G3 --> H
```

## Region selection

`RegionSelectionViewModel` geocodes the selected place and saves a new entity with no daily forecast. `HomeViewModel` sees an entity with empty `daily` and fetches it.

```mermaid
flowchart TD
    A([User selects a region]) --> B[Geocode with MKLocalSearch]
    B --> C[Save cityName, lat, lon to Realm<br/>with empty daily forecast]
    C --> D[HomeViewModel receives<br/>Realm change notification]
    D --> E{daily is empty?}
    E -- Yes --> F[Show loading indicator<br/>and fetch the daily forecast<br/>from WeatherKit for lat/lon]
    F --> G[Save forecast to Realm]
    G --> H[Realm change notification<br/>updates UI and reloads widget timelines]
    E -- No --> H
```

## Widget timeline

`Provider.getTimeline` in `NextSunnyDayWidget` requests a refresh every 5 hours. On each refresh it fetches a new forecast if a region is set and the oldest daily entry is more than 20 hours old.

```mermaid
flowchart TD
    A([getTimeline]) --> B[Load forecast from Realm]
    B --> C{cityName is set and<br/>oldest daily entry is<br/>more than 20h old?}
    C -- No --> E[Return timeline<br/>next refresh in 5h]
    C -- Yes --> D[Fetch the daily forecast from WeatherKit<br/>and save it to Realm]
    D --> E
```
