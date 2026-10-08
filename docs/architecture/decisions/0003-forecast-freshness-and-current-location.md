# 3. Forecast freshness follows WeatherKit's expiration; the current location is resolved only when fetching

- Status: Accepted (2026-10-07, #95). "When to fetch" and the widget's use of Core Location are superseded by [0006](0006-fetch-once-a-day.md) (2026-10-08, #96).

## Context

The forecast is cached per region (#94). The app needs a rule for when to fetch again, and the "current location" region needs a rule for which coordinate to use. WeatherKit's forecasts carry `metadata.expirationDate`, "the time the weather data expires" ([`WeatherMetadata`](https://developer.apple.com/documentation/weatherkit/weathermetadata)), and the usual advice is to reuse cached data until then instead of fetching on every appearance. The plan includes 500,000 calls a month ([WeatherKit](https://developer.apple.com/weatherkit/get-started/)).

## Decision

### When to fetch

A cached forecast is fetched again when **its `expirationDate` has passed, or the date has changed since it was fetched**. The date rule keeps "today" right after midnight even if the data has not expired. Pull to refresh always fetches. The widget's schedule is decided in #96.

### The current location

- Moving does not trigger a fetch. When a fetch happens (expired, new day, pull to refresh), it uses the location at that moment: get the location, reverse geocode it, fetch the forecast.
- The place name comes from `MKReverseGeocodingRequest` (iOS 26; `CLGeocoder` is deprecated) and is stored with the cached forecast. Home's toolbar and the widget show it; Settings shows "Current location". Which `MKAddressRepresentations` field to show (`cityName`, `cityWithContext`, …) is decided with the screens.
- The widget does not use Core Location for now: for the current location it fetches for the coordinate of the last cached forecast. Whether the widget resolves the location itself is decided in #96.

## Considered options

**When to fetch**

- *A fixed age (for example one hour).* The number had no basis; WeatherKit already says when its data expires.
- *Once a day.* Fewest calls, but changes during the day never show.
- *Expiration only.* Data that has not expired could still show yesterday as "today" right after midnight.

**The current location**

- *Fetch on any move.* GPS jitter would fetch constantly.
- *Fetch after moving N km.* No basis for N.
- *Fetch when the reverse-geocoded place changes.* Matches "the region changed", but needs geocoding on every move. Reconsider if the expiration turns out to be several hours, which would leave a moved user on the old place's forecast for long.

## Consequences

- Measured on 8 October 2026: WeatherKit's daily and hourly data both expire one hour after they are fetched, so the app fetches at most about once an hour while it is used, and the widget fetches on each timeline refresh.
- A user who travels far before the data expires sees the old place until they pull to refresh. The next sunny day rarely changes over a few kilometres.
