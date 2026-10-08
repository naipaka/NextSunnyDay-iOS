# 6. Forecasts are fetched once a day from 4:00, shared by the app and the widget

- Status: Accepted (2026-10-08, #96)
- Supersedes the "When to fetch" part of [0003](0003-forecast-freshness-and-current-location.md) and its note that the widget doesn't use Core Location. The rest of 0003 (the current location is resolved only when fetching) stands.

## Context

[0003](0003-forecast-freshness-and-current-location.md) fetched again when WeatherKit's expiration date passed or the date changed, and pull to refresh always fetched. WeatherKit's daily and hourly data expire a flat hour after each fetch (measured on 8 October 2026); `WeatherService` doesn't expose when the model behind the data ran, and Apple doesn't publish how often that is ([forum answer on `reportedTime`](https://developer.apple.com/forums/thread/772375)). So the expiration says how long a response may be reused, not when the forecast changes.

The calls are the constraint. The Apple Developer Program includes 500,000 WeatherKit calls a month for the whole membership ([WeatherKit](https://developer.apple.com/weatherkit/get-started/)); more calls need a paid tier, starting at US$49.99 a month for one million, which this app won't pay for. A paid tier starts only when the account holder subscribes, so going over doesn't bill; developers report that requests then fail with `OVER_QUOTA` for the rest of the month. How many people will use 2.0 can't be known, but the number of calls each person causes can be kept small, which helps however that turns out.

The app shows the next sunny day, today's hours and ten days. The first and the last barely change within a day; today's hours do, and pull to refresh is there for that. The cache holds ten days with all their hours, so a new day can be shown from it without a fetch.

WidgetKit gives a frequently viewed widget about 40 to 70 reloads a day, reloads requested while the app is in the foreground don't count, and providers should put predictable changes in the timeline instead of reloading for them ([Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)). The same page warns that a reload date shared by every device makes the server load spike.

## Decision

### Fresh until the next 4:00

A cached forecast is **fresh when it was fetched since the last 4:00**, whether the app or the widget fetched it (`CachedForecast.isFresh(at:)`). Automatic fetches don't look at WeatherKit's expiration.

- **The app** fetches when Home appears, the region changes or the app becomes active, if the forecast isn't fresh.
- **Midnight doesn't fetch.** "Today" moves to the next cached day (`WeatherForecast.days(from:)`, `SunnyLevel.nextSunnyDay(in:now:)`), and the fetch waits for 4:00.
- **Pull to refresh and the retry buttons** fetch only when WeatherKit's expiration has passed, nothing is cached, or the last fetch failed (`RegionForecast.refresh(for:)`). Pulling again within the hour ends without a call.

4:00 is early enough that the day's forecast is in place when people check it in the morning, including early risers, and late enough that it isn't spent on a fetch in the middle of the night. Knowing when WeatherKit's models run wouldn't change that reasoning, so it wasn't measured.

### The widget

- Each timeline has an entry for now and one for the next midnight, built from the same forecast, so the day count rolls over without a reload.
- The next reload is at the next 4:00 plus a random 0–60 minutes, so that devices don't all call WeatherKit at once. On reload it fetches only if the forecast isn't fresh: at most one fetch per device and day, and none on days the app already fetched.
- For the current location it resolves the location itself (`NSWidgetWantsLocation`) when it fetches, as the app does. Without the permission, or when no location comes, it uses the coordinate of the last cached forecast.

### Running out of calls

There is no dedicated message. `WeatherError` only has `permissionDenied` and `unknown`, so an exhausted quota can't be told apart from other failures; it shows as the usual "couldn't get the weather" state and banner, over the cached forecast when there is one.

## Considered options

- *Keep WeatherKit's expiration (0003).* Up to a fetch an hour while the app is used and on every widget reload, for data that mostly doesn't change.
- *Reload the widget every few hours.* Three to eight calls per device and day for the same day count; the page only changes at midnight, which the timeline handles.
- *Start the day at midnight.* The day's fetch would happen around midnight, and the forecast seen during the day would be from then. Every widget would also reload at the same time.
- *A fixed cooldown for pull to refresh (such as 15 minutes).* WeatherKit's expiration is Apple's own figure for how long a response may be reused.
- *An "out of calls this month" message.* Can't be detected reliably (see above).

## Consequences

- Each device makes about one automatic call a day, plus pulls after the hour is up. 500,000 calls a month cover roughly 16,000 people who use the app or the widget every day.
- Today's hours can be up to a day old until the user pulls to refresh.
- A widget only gets locations shortly after it was visible ([Accessing location information in widgets](https://developer.apple.com/documentation/widgetkit/accessing-location-information-in-widgets)). The 4:00 reload usually runs while the phone is locked, so it mostly fetches for the last cached coordinate; the location is updated when the app or a visible widget fetches.
- A user who opens the app before 4:00 sees the previous day's fetch, moved on by a day.
