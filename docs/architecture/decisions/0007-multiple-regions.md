# 7. Up to three regions; only the region on screen is fetched

- Status: Accepted (2026-10-09, #103)
- Builds on [0004](0004-stored-settings-format.md) (regions are a list with fixed IDs, caches keyed by ID) and [0006](0006-fetch-once-a-day.md) (a forecast is fresh until the next 4:00). Updates [0005](0005-app-layer-state.md)'s shared state: `RegionSelection` holds the saved regions and the one Home shows, not a single region.

## Context

2.0 lets the user keep several regions, such as home and a trip destination. The stored format was a list from the start (0004), but the app kept one region: `RegionSelection` held it, `RegionForecast` deleted every other region's cache on each refresh, and the widget showed the first region.

WeatherKit calls are the constraint (0006): 500,000 a month for the whole membership, about one automatic call per person and day today. Fetching every saved region each day would multiply that by the number of regions.

## Decision

### Fetching

**Only the region on screen is fetched.** Home fetches the region it shows when its cache isn't fresh, as before; each widget fetches its own region at most once a day. Saved regions are never fetched in the background. Each region keeps its cache file until it is removed, so switching shows the last forecast at once and fetches only if it is stale.

The calls then follow what people look at, not what they save, and the limit on regions is set by the screens alone.

### The list

- **Up to three regions** (`RegionList.maximumCount`). The current location is an ordinary entry, added and removed like a place, and counts as one. Someone who doesn't allow location access never carries a broken entry, and all three slots can go to places.
- **The rules live in the `Region` feature** as a value type, `RegionList`: the order, the shown region (falling back to the first), adding (a saved place or the current location is chosen instead of added again; nothing is added when full), removing (at least one region stays) and moving. They are unit-tested in the package.
- **The shown region is stored** under its own key, `selectedRegion`, next to `regions`, so the app opens on the region it showed last. Like the other keys, it is frozen from 2.0 (0004).
- `RegionSelection` (app) holds a `RegionList`, saves it on every change, reloads the widgets when the regions change, and deletes removed regions' caches through `ForecastUpdater`. `RegionForecast` no longer deletes caches.

### Screens

Home switches regions with a menu on its toolbar region button rather than by swiping between pages: the hourly strip already scrolls sideways, and the full-bleed header changes color per region. A Regions screen removes and reorders them. The screens are in [the spec](../../design/spec.md#regions).

### The widget

Each widget picks its region in its App Intent configuration (`SelectRegionIntent` with a `RegionEntity` parameter, in the widget target). Until a region is picked, and after it is removed, the widget shows the first region in the list (`RegionList.region(id:)`). The order is the user's own priority, and a widget that followed the app's shown region would switch to a trip destination after a quick look at it.

Where App Intents live for Siri and Shortcuts is left to #104; the widget's configuration only needs the entity and query it defines.

## Considered options

- *Fetch every saved region once a day.* Switching would always show a fresh forecast, but each region would add a daily call per person, for regions that may not be looked at that day.
- *Swipe between regions like the Weather app.* Conflicts with the horizontal hourly strip, and slides the full-bleed header color sideways.
- *Always keep the current location in the list.* It would show a failure state for people who don't allow location access and take one of the three slots.
- *A widget that follows the app's shown region.* Looking at another region in the app would change the Home Screen.

## Consequences

- WeatherKit calls stay about one a day per person and region looked at; people with several widgets for different regions make one call per region.
- A region that wasn't shown since the last 4:00 shows the previous day's forecast for a moment when switched to, until its fetch ends.
- Cache files are deleted only when their region is removed, so the caches directory holds at most three forecasts.
