# Architecture decision records

One file per decision: the context, the decision, the options that were considered and why they were not chosen, and the consequences. A record is not rewritten when a decision changes; a new record supersedes it and the old one's status says so.

| # | Decision |
| --- | --- |
| [0001](0001-modules-in-local-packages.md) | Shared code lives in local Swift packages, one package per module |
| [0002](0002-dependency-checks-in-ci.md) | CI checks that every import is a declared dependency |
| [0003](0003-forecast-freshness-and-current-location.md) | Forecast freshness follows WeatherKit's expiration; the current location is resolved only when fetching (freshness superseded by 0006) |
| [0004](0004-stored-settings-format.md) | Settings keys and formats are redesigned now and frozen from 2.0 |
| [0005](0005-app-layer-state.md) | The app layer keeps state where SwiftUI expects it, without per-screen view models |
| [0006](0006-fetch-once-a-day.md) | Forecasts are fetched once a day from 4:00, shared by the app and the widget |
| [0007](0007-multiple-regions.md) | Up to three regions; only the region on screen is fetched |
