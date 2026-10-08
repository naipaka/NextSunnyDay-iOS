# 5. The app layer keeps state where SwiftUI expects it, without per-screen view models

- Status: Accepted (2026-10-08, #95)
- Builds on [0001](0001-modules-in-local-packages.md): the app and the widget assemble the modules; this record covers how their screens hold state and reach the features.

## Context

Version 1 used MVVM with Combine: every screen had a view model conforming to `ViewModelObject`, split into Input, Binding and Output objects. 2.0 moves to Observation (`@Observable`), Swift Concurrency and the Swift 6 language mode.

With Observation, SwiftUI tracks each property that `body` reads, per instance; a view is not updated when a property it does not read changes. `@State`, `@Environment` and `@Bindable` replace `@StateObject`, `@EnvironmentObject` and `@ObservedObject`.

In SwiftUI, state belongs to the view that creates it: a `@State` value lives as long as that view, and is visible only to the views below it. Reacting to changes is also done by views: `body` is re-evaluated when the state it reads changes, and `task(id:)` cancels and restarts its work when its `id` changes. Observation notifies views; it is not meant to wire state holders to each other.

The goal is to follow these SwiftUI conventions as they are, keep a single source of truth for every piece of data, and keep logic out of views so it can be tested.

## Decision

### Where state lives

**State lives in the least common ancestor of the views that use it**, as Apple's documentation puts it ([Managing user interface state](https://developer.apple.com/documentation/swiftui/managing-user-interface-state), [State](https://developer.apple.com/documentation/swiftui/state)). Its place also sets its lifetime: state at the app root lives as long as the app; state in a pushed screen goes away when the screen is closed.

- **What it holds:** a plain value, or the instance of an `@Observable` class (see below). Either way it is held with `@State` by the view that owns it.
- **How it reaches the views below:** as an argument, or a `Binding` when the child changes it. When it would have to be passed through views that do not use it, or many views use it, it goes into the environment.
- **When more views need it later,** it moves up to their new common ancestor.

State whose common ancestor is the app root is called **shared state**. In 2.0 that is:

| Shared state | State holder | Used by |
| --- | --- | --- |
| The selected region | `RegionSelection` | Launch (onboarding or Home), Onboarding, Home, Settings, Region |
| The sunny level | `SunnyLevelSelection` | Home (next sunny day), Settings, Sunny level, About |
| The forecast of the selected region and its fetch status | `RegionForecast` | Home; the day detail gets the day it shows as a value |

Only Home uses the forecast directly, but Home is the root screen, shown for as long as the app runs, and the selected region can change from the Settings sheet on top of it. Keeping the forecast and its fetch status at the root keeps them across that change, next to the selected region they depend on.

Everything else (search text and results, sheet visibility, …) is `@State` in the screen that uses it.

### A value or a class

A screen keeps its state as **plain values** when every update replaces a value with user input or the result of one call.

It uses an **`@Observable` class**, held with `@State`, when updating the state is logic:

- an update depends on the current state (appending a page, merging results, counting retries), or
- one operation has to change several values consistently, or
- several operations of the screen work on the same state.

That logic then lives in the class and is tested there. Shared state always lives in `@Observable` classes, which are created at the app root and put into the environment.

### State holders do not depend on each other

The `@Observable` classes that hold state are called **state holders** (the term from Android's architecture guide; Apple has no specific term and calls any `@Observable` type a "model").

- Each state holder holds its state and the operations on it, and does not reference other state holders. There is no object that gathers all shared state.
- **The view that needs two pieces of state combines them.** For example, Home reads the forecast and the sunny level and passes both to the `SunnyDay` feature to get the next sunny day.
- **Views say when work happens:** `task(id:)` for work that depends on a value (fetching when the selected region changes), `refreshable` for pull to refresh. How the work is done (freshness, fetching, failures) is in the state holder or the feature.

### Views and features

See *Dependencies and test doubles* below for how views and state holders get the features.

**Views contain no logic.** Decisions, conversions and error policies live in features and state holders. A view only reads state, says when something happens and where the result goes:

- **In `body`, a view only reads state and computes without side effects.** `body` can run at any time and any number of times.
- **Side effects go only in event and lifecycle closures:** button actions, `task` / `task(id:)`, `refreshable`, `onChange`.

What the view does with a result depends on who owns it:

| To | Where | The view |
| --- | --- | --- |
| Change shared state | An event or lifecycle closure | Calls the state holder, which calls the features and updates its state. Selecting a region: `regionSelection.select(…)` |
| Change the screen's own state | An event or lifecycle closure | Calls a feature and puts the result into its `@State`. The region search: `results = await search(query)` in `task(id: query)` |
| Compute a value from state | `body` | Passes the state it reads to a feature's function without side effects and uses the result. The next sunny day |

- **The region search:** the text and the results are `@State` in the Region screen. `task(id:)` on the text cancels the previous search, waits briefly to debounce, and calls the `Region` feature's search function. Rules such as a minimum length and turning completions into region candidates are in the feature.
- **The next sunny day:** Home computes it in `body` from `RegionForecast` and `SunnyLevelSelection` with the `SunnyDay` feature's function, which holds the sunny rules (including the 30 % rule) and is tested there. It is not stored. `body` is re-evaluated only when the forecast or the sunny level changes, and the computation looks at ten days. The widget calls the same function.

### When the forecast is fetched

[0003](0003-forecast-freshness-and-current-location.md) decides when a cached forecast is stale. Only Home shows the forecast, so Home starts every fetch:

| When | Call | In Home |
| --- | --- | --- |
| Home first appears, the selected region changes, the app becomes active, the date changes | Fetch if stale | One `task(id:)` |
| Pull to refresh | Always fetch | `refreshable` |
| Retry and "try again" buttons | Always fetch | The button's action |

```swift
.task(id: RefreshKey(region: regionSelection.region, isActive: scenePhase == .active, day: today)) {
  guard scenePhase == .active, let region = regionSelection.region else { return }
  await regionForecast.refreshIfNeeded(for: region)
}
```

- One `task(id:)` states the rule in one place: when the region, the scene being active or the day changes, fetch if stale. SwiftUI cancels the running work and starts again whenever the key changes.
- Whether the app is active comes from `scenePhase`. `today` is updated on [`significantTimeChangeNotification`](https://developer.apple.com/documentation/uikit/uiapplication/significanttimechangenotification), which the system posts at midnight, so a forecast stays right when the app is left open across midnight.
- The region can change from the Settings sheet; Home stays in the view tree under the sheet and reacts to the change.
- **`RegionForecast` does not treat cancellation as a failure.** Moving the app to the background cancels a running fetch, and the fetch starts again when the app becomes active; showing the error banner for that would be wrong.

### Dependencies and test doubles

**How parts get what they use**

| Who | Gets | How |
| --- | --- | --- |
| A state holder | The features it calls | Its initializer. State holders are created at the app root, where the features are created too |
| A view | A shared state holder | `.environment(_:)`, read with `@Environment(Type.self)` (only `@Observable` classes can be put into the environment by type) |
| A view | A feature it calls directly (the region search) | An `EnvironmentValues` entry declared with `@Entry`, read with `@Environment(\.key)` |
| A view | A function without side effects (the next sunny day) | Nothing: it imports the feature and calls the function |

- A view gets something through the environment when passing it as an argument would go through views that do not use it; otherwise as an argument.
- No singletons (`.shared`): they cannot be replaced in previews and tests. No dependency injection library: the repository has no third-party dependencies, and initializers plus the environment cover what the app needs.

**Test doubles: real implementations unless they are slow, nondeterministic or hard to build**

Tests use the real implementation of what a part depends on, and a test double only where the real one is not fast, not deterministic or not simple to build. This is the rule of Google's [Software Engineering at Google](https://abseil.io/resources/swe-book/html/ch13.html) ("prefer realism over isolation"). It decides where doubles go in any app, not only this one.

Here, only the outside world (WeatherKit, Core Location, MapKit) fails those conditions: it needs the network, permissions and entitlements, and its answers change. So the core modules are the only thing replaced in tests and previews. The features are fast, deterministic and simple to build on fakes of the core modules, so every layer above the core runs its real code. If a feature stops meeting the conditions, that feature gets a fake.

| Tests of | Run with |
| --- | --- |
| Core | Their own logic only, such as turning WeatherKit's values into the module's types. Talking to the real services is checked in the running app |
| Features | Fakes of the core modules; real `UserDefaults` with a test suite and real files in a temporary directory ([0001](0001-modules-in-local-packages.md)) |
| State holders | Real features built on fakes of the core modules |
| Previews | The same: real features and state holders on fakes of the core modules, assembled in one place |

- Each test checks only what its part promises; the parts below just run. A defect in a feature is caught by the feature's own tests, which point at it even when a state holder's tests fail too.
- Fakes are lightweight working implementations, not mocks that check which calls were made: interaction checks tie tests to implementation details.
- Each core package provides the fake of its module in a separate module named `…Testing` (for example `WeatherTesting` in the `Weather` package), so whoever changes the real module sees the fake next to it, and the app does not ship the fake. Apple's own packages do the same (`InMemoryLogging` in swift-log, `MetricsTestKit` in swift-metrics, `NIOEmbedded` in swift-nio), as do Vapor (`VaporTesting`) and Wikipedia's `WMFData` package (`WMFDataMocks`).
- **Fakes of the outside world use recorded data.** WeatherKit's types (`Weather`, `DayWeather`, `HourWeather`, `Forecast`) are `Codable`, so responses are fetched once on a device, saved as JSON and decoded in tests. Whether MapKit search results and Core Location values can be recorded the same way is checked when implementing those modules.

### Swift settings

The targets follow Xcode 26's new-project template, except for the language mode:

| Target | Language mode | Default isolation | Approachable Concurrency | Member Import Visibility |
| --- | --- | --- | --- | --- |
| App | Swift 6 | `MainActor` | Yes | Yes |
| Widget extension | Swift 6 | nonisolated | Yes | Yes |
| App tests | Swift 6 | nonisolated | Yes | Yes |
| Packages ([0001](0001-modules-in-local-packages.md)) | Swift 6 (the default for tools version 6.2) | nonisolated | `NonisolatedNonsendingByDefault` and `InferIsolatedConformances` | `MemberImportVisibility` |

- The template (checked in Xcode 26.4.1) sets `MainActor` default isolation for app targets only, and Approachable Concurrency and Member Import Visibility for every target. It still sets Swift 5; Swift 6 is what this issue moves to, and Apple's recent samples (Landmarks, the Foundation Models trip planner, the MapKit points of interest sample) use it too.
- In Swift 6 mode, Approachable Concurrency adds two features over the language mode: `NonisolatedNonsendingByDefault` (SE-0461: nonisolated async functions run on the caller's actor) and `InferIsolatedConformances` (SE-0470). Packages enable the same two, so async code behaves the same in the app and in the packages.
- Member Import Visibility (SE-0444) makes members of a module usable only where that module is imported, which matches the rule that every used module is a declared, imported dependency ([0002](0002-dependency-checks-in-ci.md)).
- Tests of `MainActor` state holders are marked `@MainActor`.

### Naming

State holders are **named after their role, with no common suffix** (Swift API Design Guidelines: name things according to their roles):

- when the role is a thing or a piece of state, a noun for it;
- when the role is one job, a word for that job.

What a state holder contains is told by its property names, not by its type name.

- `RegionSelection` and `SunnyLevelSelection` both hold a choice the user made and the app stores, so they share the word *Selection*: the same role gets the same word. `SelectedRegion` would read like the region value itself, and *current* is avoided because the user can pick the current location.
- `RegionForecast` holds the forecast of the selected region and its fetch status. It is named after what screens read from it, not after fetching: caching, freshness and fetching are done by the `Forecast` feature.


## Considered options

**Where state lives**

- *All state at the app root, handed out through the environment.* Then every piece of state lives as long as the app, and state that only one screen uses is shared with every screen. Placing state at the common ancestor gives each piece the scope and lifetime it needs.
- *A view model per screen (MVVM).* Each screen copies the shared data it shows into its own object, so the same data exists in several places and has to be kept in sync.
- *One object for all shared state.* Apple's small samples do this (`ModelData` in Landmarks). It grows with every feature and makes every test set up everything. Larger apps split shared state by concern (Ice Cubes puts more than ten objects into the environment).
- *State holders that depend on each other*, each observing the state holders it needs (for example the forecast observing the selected region with `Observations`) or a parent object owning and wiring them (Point-Free's SyncUps). This rebuilds a dependency graph next to the one SwiftUI already has in the view tree. Apple's samples and Ice Cubes react to changes in views with `task(id:)` instead (Food Truck refetches the weather with `task(id: city.id)`).
- *A state holder for every screen-local concern with I/O*, such as a class for the region search. For a search that only replaces its results, `@State` and `task(id:)` do the same with less code. Apple's MapKit sample (Interacting with nearby points of interest) keeps search completions in `@State` too.

**Views and features**

- *Views never call features; every call goes through a state holder.* SwiftUI's own pattern is that a view starts asynchronous work and keeps the result in its state: [`task(id:)`](https://developer.apple.com/documentation/swiftui/view/task(id:priority:_:)) restarts the work when a value changes, Food Truck fetches the weather in its city view with `task(id: city.id)`, and the MapKit sample keeps search completions in `@State`. Requiring a state holder for every call would add a class where SwiftUI needs none. What has to stay out of views is logic, not calls.
- *Views calling core services directly*, as Apple's samples call `WeatherService` and MapKit. Core modules are used by features ([0001](0001-modules-in-local-packages.md)), and rules such as a minimum search length belong in a feature, where they are tested.

**Computing the next sunny day**

- *A method of `RegionForecast` taking the sunny level*, or *of `SunnyLevelSelection` taking the forecast.* Either is a thin wrapper around the feature's function and makes one state holder know about the other's concern.
- *A state holder of its own.* There is no state to hold.

**Starting fetches**

- *A separate `onChange(of: scenePhase)` starting a `Task`.* The task is not tied to the view, so it is not cancelled when the region changes or the app leaves the foreground, and two fetches can overlap.
- *A timer to notice midnight.* The system already posts a notification for a new day.
- *Fetching from the app root instead of Home.* Only Home shows the forecast; before a region is chosen there is nothing to fetch.

**Test doubles**

- *Fakes at every boundary,* including a fake of each feature for state holder tests. A state holder test then checks the state holder alone, and a failure points at it directly. But every feature needs a fake, kept in a module of its own, and tests that run the real feature and its fake against the same promises so the fake does not drift from the real one. All of that buys only faster locating of a failure, which the feature's own tests already give. Android's guide fakes the layer below a view model this way ([Use test doubles](https://developer.android.com/training/testing/fundamentals/test-doubles)); Google's [Software Engineering at Google](https://abseil.io/resources/swe-book/html/ch13.html) prefers real implementations when they are fast, deterministic and simple to build, which the features are on fakes of the core modules.
- *Hand-written sample data for the outside world.* It encodes a guess of what the services return; if the guess is wrong, every test above it is wrong too.

**Swift settings**

- *Swift 5 mode, as in the template.* Large existing apps stay on it to avoid the migration (Wikipedia and WordPress even pin their Swift 6 tools packages to `.v5`); this app is rewritten for 2.0, and moving to Swift 6 is the point of this work.
- *`MainActor` default isolation for the widget extension too.* Both compile (a `TimelineProvider` and a `Widget` type-check either way with the iOS 26 SDK), and the widget's code is small; the template leaves extensions nonisolated. Revisit in #96 if the widget needs it.
- *`MainActor` default isolation for the packages.* Core and feature modules have no UI; [0001](0001-modules-in-local-packages.md) keeps them nonisolated.

**Debouncing the search**

- *The search text in a state holder, observed with `Observations`*, or *Combine's `debounce`* as in version 1. Both need code to cancel the previous search; `task(id:)` cancels it when the text changes, so waiting with `Task.sleep` at its start is enough.

**Naming**

- *`…ViewModel`*: implies MVVM. Most large apps surveyed use it (Wikipedia, WordPress, DuckDuckGo, Home Assistant, Signal), with one per screen.
- *`…Model`*: Apple's samples use it (`FoodTruckModel`, `MapModel`, `PlayerModel`), and so do Point-Free's SyncUps (`SyncUpDetailModel`) and Flutter's docs (`CartModel`). But Apple also calls plain data types "models" (`Book`), so the suffix does not tell a state holder from a data type.
- *`…Store`*: clashes with the features' role names (`RegionStore`).
- *`…State`*: Jetpack Compose's convention for state holders (`LazyListState`), but easy to confuse with SwiftUI's `@State`.
- *Named after the owning screen plus a suffix* (`SyncUpDetailModel`, `NewsViewModel`, `LazyListState`). This gives uniform names in designs with one state holder per screen; here state holders follow the state, not the screens.

The surveyed code that does not use MVVM (Apple's recent samples, Ice Cubes) has no common suffix either. It names each state holder by what it is or does: `LocationFinder`, `ItineraryPlanner`, `LocationLookup`, `AccountStatusesFetcher`, `CurrentAccount`, `Library`.

## Consequences

- Not yet checked on a device: that `task(id:)` in Home keeps reacting while the Settings sheet covers it. If it does not, the trigger for a region changed in the sheet is revisited when implementing Home.

- Fetching when the selected region changes is declared in a view, so it is checked in the running app and previews, not by unit tests. The fetching itself is unit-tested in the state holder and the feature.
- Previews are in the app target, so the app links the `…Testing` modules. `#Preview` is compiled in every configuration, so `PreviewHost` can't be limited to `DEBUG`, and the fakes' protocol conformances keep their small types in the release binary. The WeatherKit recordings are not bundled: `WeatherTesting` reads them from its source folder, which tests and previews on the Mac or a simulator can reach. Shipping recorded WeatherKit data in the app is avoided this way.
- State holder names do not share a suffix, so they cannot be listed by name pattern. They are found by their place in the app target.
