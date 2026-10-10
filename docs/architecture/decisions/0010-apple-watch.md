# 10. Apple Watch: settings come from the iPhone, the forecast is fetched on the watch

- Status: Accepted (2026-10-10, #107)
- Builds on [0001](0001-modules-in-local-packages.md) (modules), [0004](0004-stored-settings-format.md) (stored settings), [0006](0006-fetch-once-a-day.md) (a fetch a day from 4:00), [0007](0007-multiple-regions.md) (regions, and the widget's region) and [0008](0008-app-intents.md) (`RegionEntity` in a package).

## Context

2.0 shows the next sunny day on the watch face. Complications are a WidgetKit extension, and on watchOS a widget extension is embedded in a watch app, so a watch app ships either way.

The watch is another device: the App Group the app and the widget share on the iPhone (0004) is not visible there. The watch needs the saved regions, the sunny level and the temperature unit from the iPhone, and a forecast for the region it shows.

Some facts decide how:

- **WeatherKit works on watchOS**, and the watch can fetch on its own when the iPhone is out of reach or its app hasn't run for days. Calls are the constraint (0006): about one a day per region looked at.
- **WatchConnectivity's application context** keeps only the latest dictionary the iPhone sent and delivers it when the watch app runs, waking it in the background for that (`WKWatchConnectivityRefreshBackgroundTask`, `.backgroundTask(.watchConnectivity)` in SwiftUI). Settings change rarely and only the latest values matter.
- **A watch widget can't ask for the location.** `CLLocationManager.isAuthorizedForWidgetUpdates` is unavailable on watchOS (watchOS 27 SDK).
- **watchOS has no Edit Widget screen.** A configurable complication offers its configurations through `recommendations()`, and the face's editor lists one complication per recommendation.
- The iPhone's Lock Screen widgets (circular, rectangular, inline) are the same accessory families the watch face uses; the watch adds the corner.

## Decision

### Targets

| Target | Folder | Contents |
| --- | --- | --- |
| `NextSunnyDayWatch` (watch app, embedded in the iPhone app) | `NextSunnyDayWatch/` | One screen and a region picker; its own small state holders |
| `NextSunnyDayWatchWidgetExtension` (embedded in the watch app) | `NextSunnyDayWidget/` and `NextSunnyDayWatchWidget/` | The iPhone widget's code, plus the watch's entry point, the corner and `Provider+watchOS.swift` |

The watch app is not independent (`WKRunsIndependentlyOfCompanionApp` is `NO`): without the iPhone app it has no regions.

### Settings come from the iPhone

- A core module, **`WatchSync`**, copies `UserDefaults` values from the iPhone to the watch. `SettingsMirror` reads the values of some keys into a context and writes a context back; `SettingsSync` (WatchConnectivity) sends it from the iPhone and applies it on the watch. It knows nothing about the features: the keys are `RegionStore.key`, `SunnyLevelStore.key` and `TemperatureUnitStore.key`, and the values are copied in their stored format (0004), so the watch reads them with the same stores. A key the iPhone doesn't have is removed on the watch.
- **The region each device shows is its own.** `selectedRegion` isn't copied: looking at a trip destination on the iPhone doesn't change the watch, as with the widget (0007). The watch shows the region chosen on it, else the first.
- The iPhone sends when the regions, the level or the unit change (`RootView`), after the session activates, and when the watch app is installed later (`sessionWatchStateDidChange`).
- The watch applies the context in the app, also when woken in the background, then reloads the complications, asks for new recommendations and deletes the caches of removed regions.
- Notification settings aren't copied: the watch shows the iPhone's notifications, so the `Notifications` and `Notice` packages don't build for watchOS.

### The forecast is fetched on the watch

- The watch keeps its own forecast cache in its own App Group container, with the same rules: fresh until the next 4:00 (0006), only the region on screen (0007). The watch app fetches as Home does; the complications fetch at most once a day, from the same `Provider`.
- **The current location:** the watch app looks it up when it fetches (asking for permission on the watch). The complications use the coordinate of the last cached forecast, because a watch widget can't ask for the location.

### Shared code

- **The watch's complications compile the iPhone widget's folder.** `NextSunnyDayWidget/` is synchronized to both widget targets. What differs is in two files with the same functions: `Provider+iOS.swift` (location for widgets, notifications, the Apple Weather mark) and `NextSunnyDayWatchWidget/Provider+watchOS.swift` (no location, no notifications, recommendations). The iPhone-only files (`NextSunnyDayWidget.swift`, `HomeScreenViews.swift`, `AttributionMarkCache.swift`, `Provider+iOS.swift`, `WidgetPreviews.swift`, `Info.plist`) are membership exceptions of the watch's target.
- The few differences inside shared views are `#if os(watchOS)`: watchOS has no numbered system grays, and the rectangular complication gives the answer more room.
- **The watch app keeps its own state holders**, `SyncedSettings` and `WatchForecast`, with the iPhone's rules for showing the cache and fetching. Its wording and formats are a few lines, like the widget's, and come from the shared `Localizable.xcstrings`.
- The `RegionIntents` module (0008) is used by the watch's complications; the watch app doesn't use App Intents.

## Considered options

- *The iPhone sends the forecast too.* The watch would make no calls, but the complications would stop updating whenever the iPhone app doesn't run, and the payload would be a whole cache file per region.
- *iCloud key-value storage for the settings.* Needs an iCloud account, syncs on iCloud's schedule, and adds a capability for what a paired watch already has a channel for.
- *A typed settings payload in a package.* A type holding regions, level and unit would combine three features, which only the targets do (0001). Copying stored values keeps the format in the stores that own it.
- *A copy of the widget code for the watch.* Two copies of the same views and timeline would drift.
- *The app's state holders in a package for the watch app.* They combine features and belong to the app layer (0005); the watch's versions are small.

## Consequences

- People who look at the watch make about one more WeatherKit call a day per region the watch shows.
- A complication for the current location shows nothing until the watch app has fetched once.
- Watch-only text is in `Localizable.xcstrings` like the rest; a few lines of formatting exist in the app, the widget and the watch app.
- WatchConnectivity works only between a paired iPhone and watch, including in the simulator (`xcrun simctl pair`).
