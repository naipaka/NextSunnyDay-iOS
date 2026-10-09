# 8. App Intents: the shared entity in a package, the intents in the targets that run them

- Status: Accepted (2026-10-09, #104)
- Builds on [0001](0001-modules-in-local-packages.md) (modules and who assembles them), [0005](0005-app-layer-state.md) (state holders and how parts get features) and [0007](0007-multiple-regions.md) (the widget's region configuration, which left the place of App Intents to this record).

## Context

Siri, Shortcuts and Spotlight answer 「次いつ晴れる？」 with an App Intent. The intent takes a saved region, the same `RegionEntity` the widget's configuration uses. That entity was defined in the widget target, so the app couldn't use it, and the Watch app (#107) will need it too.

Two facts about App Intents decide where the types can go:

- **An entity shared by several targets has to live in a module that each of them includes.** Since Xcode 26 that can be a Swift package: the module declares an `AppIntentsPackage`, and each target that uses its types declares its own `AppIntentsPackage` that includes it (WWDC25 "Get to know App Intents"). Before that, Apple's answer was a dynamic framework target.
- **An `AppShortcutsProvider`, and the intents it lists, must be in the app target.** The system reads App Shortcuts from the app's bundle.

An App Intents type also carries text the system shows: an entity's type name and each instance's display representation, an intent's title and parameter titles, the dialog. Checked with Xcode 27.1 on an iOS 27.0 simulator, this text comes in two kinds:

| Text | Example | Made | Where the translation is looked up |
| --- | --- | --- | --- |
| Run-time | An entity's display representation (「現在地」), an intent's dialog | By the code, while it runs | The bundle the `LocalizedStringResource` names: a package's own String Catalog works with `bundle: #bundle` |
| Metadata | An entity's type name, intent and parameter titles, App Shortcut phrases | By the build, into `Metadata.appintents` | The host's bundle (app or extension): the metadata stores only the key |

The metadata kind explains reports of package intents showing their keys untranslated (Apple Developer Forums thread 806804, Xcode 26.1): the strings were in the package's catalog only.

## Decision

### Where the types live

| Type | Where | Why |
| --- | --- | --- |
| `RegionEntity`, `RegionEntityQuery`, `RegionIntentsPackage` | `RegionIntents`, a second module of the `Region` package | Used by the app, the widget and later the Watch; depends on `Region` only |
| `SelectRegionIntent` (the widget's configuration) | The widget target | Only the widget uses it |
| `NextSunnyDayIntent`, `NextSunnyDayShortcuts` | The app target, in `NextSunnyDay/Intents/` | App Shortcuts must be in the app; answering combines `Region`, `Forecast`, `SunnyDay` and `Units`, which only the app and the widget assemble (0001) |

- `RegionIntents` is a separate module, not part of `Region`, so the `Region` feature keeps no AppIntents import and its role (the list of regions and its rules) stays the same. It depends on `Region` only and on no other feature.
- Each target that uses `RegionEntity` declares an `AppIntentsPackage` including `RegionIntentsPackage` (`NextSunnyDayIntentsPackage` in the app, `WidgetIntentsPackage` in the widget).

### Text in a shared module

**A module may carry the general names of its own concept**, such as 「地域」 and 「現在地」 for a region: they read the same in any app, like the condition names the `Weather` module returns. The app's own wording (「次の晴れは」, 「まだ先かも」, the dialog) stays in the app's catalog.

- `RegionIntents` has its own `Localizable.xcstrings`, and its run-time strings name it with `bundle: #bundle`, so the module is complete on its own.
- **Metadata strings are also in each host's catalog** under the same key, because the system resolves them from the host's bundle. For `RegionIntents` that is the type name "Region". A target that starts including the module adds the key.

### The intent

- `NextSunnyDayIntent` takes an optional region. Without one, or after it was removed, it answers for the first region in the list, the widget's rule (0007). It has no sunny level parameter: it uses the app's setting, so the app, the widget and Siri agree.
- A region asked about is a region looked at (0007): the intent shows its cache and fetches only when it isn't fresh (0006), through a `RegionForecast` of its own, the same rules as Home. When the fetch fails, the cached forecast answers.
- What it says is a value, `SunnyDayAnswer` (sunny, none in range, no data, no region), computed by `AppFeatures.nextSunnyDayAnswer(regionID:)` and tested with the features on fakes. The dialog and the snippet (`SunnyDaySnippet`, the small widget's layout) are made from it.
- The intent gets the features through `AppDependencyManager` (`@Dependency`), registered in `NextSunnyDayApp.init` with the same `AppFeatures` the screens use. It is Apple's way to hand dependencies to intents, which the system creates with no arguments; it keeps 0005's rule of no singletons, and a `-PreviewScenario` launch runs the intent on the fakes too.
- The phrases are in `NextSunnyDayShortcuts`; their Japanese versions are in `NextSunnyDay/Resources/AppShortcuts.xcstrings`, where each language has its own list of phrases.

## Considered options

- *An entity in each target that uses it.* Keeps every package free of App Intents and text, at the cost of a copy per target: two now, up to four with the Watch app and its complications.
- *A framework target for the shared App Intents types*, as Apple suggested before packages were supported. It adds a target and a bundle outside the package structure of 0001, for what a package now does.
- *The entity in the `Region` module itself.* The feature would import AppIntents and carry system-facing text next to its rules.
- *The shared module's strings only in the host's catalog* (no catalog in the module). Works, but the module then depends on every host having its keys, which nothing checks; a host that misses one shows English without an error.
- *A sunny level parameter.* Shortcuts could ask for laundry days with a looser level, but the answer would then disagree with the app and the widget, and #106 adds a laundry-day level of its own.
- *Fetching in the intent through `ForecastUpdater` and `RegionLocator` directly*, as the widget's `Provider` does. `RegionForecast` already holds the app's rules for showing the cache and fetching when stale, and it is tested.

## Consequences

- A new target that uses `RegionEntity` (the Watch app, #107) declares an `AppIntentsPackage` including `RegionIntentsPackage` and adds the key "Region" to its catalog.
- Metadata strings can't be checked by the module's tests; a missing key shows up only as English text in Shortcuts or a widget's configuration.
- In the iOS 27.0 simulator the dialog shown by Spotlight is in English while the device is in Japanese, and so is the system's own Done button, so the process that shows the result runs in English there. The app's tests check the Japanese dialog; Siri on a device is checked before the release (#100).
