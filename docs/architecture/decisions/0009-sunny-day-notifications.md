# 9. Notifications before a sunny day are scheduled from the cached forecast

- Status: Accepted (2026-10-10, #105)
- Builds on [0001](0001-modules-in-local-packages.md) (modules), [0004](0004-stored-settings-format.md) (stored settings are frozen), [0006](0006-fetch-once-a-day.md) (a fetch a day from 4:00) and [0007](0007-multiple-regions.md) (only the region on screen is fetched).

## Context

2.0 tells the user the day before a sunny day. A local notification is scheduled for a date and delivered by the system; once scheduled, it goes out unless the app cancels it, and the app gets no chance to run at that moment.

Notifications follow the forecast, so it has to be updated when the app isn't used. Two facts limit how:

- **WeatherKit calls** (0006, 0007): about one a day per region looked at. A background refresh for notifications would add calls for people who don't open the app.
- **`BGAppRefreshTask`** runs when the system decides, for up to 30 seconds ([Choosing background strategies for your app](https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app)). It can't promise a fetch before a given evening.

The forecast already changes in three places: the app's fetch when Home shows a region, the widget's daily fetch from 4:00, and the Siri intent's fetch. `UNUserNotificationCenter` is "for your app or app extension" ([UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter)), so the widget extension can schedule the app's notifications too.

The HIG advises against several notifications for the same thing ([Notifications](https://developer.apple.com/design/human-interface-guidelines/notifications)).

## Decision

### What is notified

- **One region:** the first saved region, or the one chosen in the notification settings. After the chosen one is removed, the first region is used again, like the widget (0007).
- **Once per sunny spell:** a notification the day before a day that counts as sunny at the user's level, when that day before doesn't. A week of sunny days is announced once, not every evening.
- **At the chosen time,** 19:00 by default, so the next day can be planned the evening before.
- The rule is `NoticeSetting.notices(in:fetchedAt:now:calendar:isSunny:)` in the `Notice` feature. It takes the sunny rule as a function, so the feature doesn't depend on `SunnyDay`.

### No background refresh

**Notifications are scheduled from the cached forecast** whenever it changes or a setting that affects them changes. No fetch is made for them, so the WeatherKit calls stay as they are (0006, 0007).

- **The app** schedules them again when the setting, the regions, the sunny level, the temperature unit or the shown forecast changes, and when it becomes active, which covers fetches by the widget or Siri (`RootView`'s `task(id:)`).
- **The widget** schedules them after it fetched the notified region, because its 4:00 fetch often runs on days the app isn't opened.
- **Siri and Shortcuts** schedule them after answering (`AppFeatures.nextSunnyDayAnswer(regionID:)`).

Each of them replaces every pending notice (IDs starting with `sunny-day-`), so the last forecast always wins.

### Only recent forecasts

**A notification is scheduled only when it goes out at most two days after its forecast was fetched** (`NoticeSetting.maximumForecastAge`). Without a fetch, a scheduled notification can't be taken back; a missing notification is better than a wrong one from a forecast several days old. With one day, a forecast fetched in the morning wouldn't cover the next evening, so people who open the app every day would miss some.

### Modules

| Module | Layer | Does |
| --- | --- | --- |
| `Notifications` | core | Wraps UserNotifications: permission, replacing pending notifications by an ID prefix, and `NotificationResponder` (the delegate that reports a notification opened and the system's request to show the app's notification settings). `NotificationsTesting` has `FakeNotificationScheduler`. |
| `Notice` | feature | The setting (`NoticeSetting`, `NoticeSettingStore`), the rule above, and `NoticeScheduler`, which turns notices into notifications for a region. Depends on `Weather`, `Notifications` and `AppGroup`. |

- **The wording stays in the targets.** `NoticeScheduler` takes the text as a function (`NoticeText`), and the app and the widget each word it the same way from `Localizable.xcstrings`, which both share. A notification is the app's own wording, which 0008 keeps out of packages. The widget's copy is a few lines, like its other formatting.
- The app holds the setting in a fifth state holder, `NoticeSelection`. Scheduling reads everything from the stores (`AppFeatures.scheduleNotices(now:)`), so the same function serves Home, Settings and the intent, and state holders still don't depend on each other.
- **Settings are stored** under `noticeOn` (Bool), `noticeRegion` (the region's ID, absent for the first region) and `noticeTime` (minutes after midnight), frozen from 2.0 like the other keys (0004).

### Permission

Permission is asked when the user turns notifications on, not at launch. The request includes `providesAppNotificationSettings`, so the system's notification settings for the app link to its Notifications screen. When the user turns notifications off in the system's settings, the switch shows off and the screen links to those settings.

## Considered options

- *`BGAppRefreshTask` once a day.* More calls for people who don't open the app, and no guarantee that it runs before the evening.
- *Every saved region.* A fetch per region and day to keep them fresh (0007), and up to three notifications an evening.
- *Every evening before a sunny day.* A notification each evening of a sunny week; the HIG advises against it.
- *No age limit.* A notification could announce a sunny day from a forecast a week old.
- *The wording in the `Notice` module's own catalog.* It would remove the widget's copy, but put the app's wording in a package (0008).

## Consequences

- Someone who neither opens the app nor has a widget for the notified region gets no notification once the forecast is more than two days old.
- The widget schedules notifications from an extension, which the documentation allows; the app's scheduling was tried in the simulator, the widget's is checked on a device before the release (#100).
- The notification text is in the language of the moment it was scheduled.
