import Forecast
import Region
import SunnyDay
import SwiftUI
import Weather

/// The next sunny day, the next 24 hours and ten days for the selected region, with a menu to
/// switch between the saved regions.
struct HomeView: View {
  let region: SavedRegion

  @Environment(RegionForecast.self) private var regionForecast
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(NoticeSelection.self) private var noticeSelection
  @Environment(\.scenePhase) private var scenePhase
  @State private var path: [HomeRoute] = []
  @State private var isShowingSettings = false
  /// The screen Settings opens on, when it isn't its first.
  @State private var settingsRoute: SettingsRoute?
  @State private var today = Calendar.current.startOfDay(for: .now)

  /// When any of these change, the forecast is fetched if it is stale. A new day only moves
  /// "today" within the cached days; the fetch waits for 4:00 (ADR 0006).
  private struct RefreshKey: Equatable {
    var region: SavedRegion
    var isActive: Bool
    var day: Date
  }

  var body: some View {
    NavigationStack(path: $path) {
      LayeredScreen(tone: headerTone) {
        HomeHeader(
          state: headerState,
          today: todayForecast,
          retry: { Task { await regionForecast.refresh(for: region) } })
      } content: {
        content
      }
      .toolbar { toolbar }
      .navigationDestination(for: HomeRoute.self) { route in
        switch route {
        case .day(let index): DayDetailView(initialIndex: index)
        case .regions: RegionListView()
        case .addRegion: AddRegionView()
        }
      }
      .sheet(isPresented: $isShowingSettings) {
        SettingsView(route: settingsRoute)
      }
      .refreshable {
        await regionForecast.refresh(for: region)
      }
    }
    .onChange(of: noticeSelection.isSettingsRequested, initial: true) { _, isRequested in
      // The system's notification settings asked for the app's.
      guard isRequested else { return }
      noticeSelection.isSettingsRequested = false
      settingsRoute = .notifications
      isShowingSettings = true
    }
    .onAppear {
      // Before the first frame, so that a cached forecast never flashes the loading state.
      regionForecast.showCached(for: region)
    }
    .task(id: RefreshKey(region: region, isActive: scenePhase == .active, day: today)) {
      guard scenePhase == .active else { return }
      await regionForecast.refreshIfNeeded(for: region)
    }
    .task {
      // Posted at midnight, so "today" moves on while the app stays open.
      for await _ in NotificationCenter.default.notifications(
        named: UIApplication.significantTimeChangeNotification)
      {
        today = Calendar.current.startOfDay(for: .now)
      }
    }
  }

  // MARK: - State

  private var cached: CachedForecast? {
    regionForecast.forecast.flatMap { $0.regionID == region.id ? $0 : nil }
  }

  private var headerState: HomeHeader.State {
    guard let cached else {
      if let failure = regionForecast.failure { return .noData(failure) }
      return .loading
    }
    let next = sunnyLevelSelection.level.nextSunnyDay(in: cached.forecast.daily, now: today)
    return next.map(HomeHeader.State.sunny) ?? .noneInRange
  }

  /// Today's forecast, shown beside the answer.
  private var todayForecast: DayForecast? {
    cached?.forecast.days(from: today).first.flatMap {
      Calendar.current.isDate($0.date, inSameDayAs: today) ? $0 : nil
    }
  }

  private var headerTone: HeaderTone {
    switch headerState {
    case .sunny: .sunny
    case .noneInRange: .gray
    case .loading, .noData: .noData
    }
  }

  private var regionName: Text {
    if let name = region.placeName ?? cached?.placeName {
      Text(verbatim: name)
    } else {
      Text("Current Location")
    }
  }

  /// The region menu's choice; choosing changes the region Home shows.
  private var selectedRegionID: Binding<String> {
    Binding(
      get: { region.id },
      set: { id in
        if let chosen = regionSelection.regions.first(where: { $0.id == id }) {
          regionSelection.select(chosen)
        }
      })
  }

  // MARK: - Content

  @ViewBuilder private var content: some View {
    if let cached {
      if regionForecast.failure != nil {
        RefreshFailedBanner(fetchedAt: cached.fetchedAt) {
          Task { await regionForecast.refresh(for: region) }
        }
      }
      NextHoursCard(hours: cached.forecast.hourly)
      DaysCard(days: cached.forecast.days(from: today), level: sunnyLevelSelection.level)
      AttributionFooter(fetchedAt: cached.fetchedAt)
    } else if let failure = regionForecast.failure {
      NoDataCard(failure: failure)
    } else {
      LoadingPlaceholder()
    }
  }

  @ToolbarContentBuilder private var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Menu {
        Picker(selection: selectedRegionID) {
          ForEach(regionSelection.regions) { saved in
            if let name = saved.placeName {
              Label {
                Text(verbatim: name)
              } icon: {
                Image(systemName: "mappin")
              }
              .tag(saved.id)
            } else {
              Label("Current Location", systemImage: "location.fill").tag(saved.id)
            }
          }
        } label: {
          EmptyView()
        }
        .pickerStyle(.inline)
        Section {
          if !regionSelection.list.isFull {
            Button("Add Region", systemImage: "plus") {
              path.append(.addRegion)
            }
          }
          Button("Edit Regions", systemImage: "list.bullet") {
            path.append(.regions)
          }
        }
      } label: {
        HStack(spacing: 6) {
          if region.kind == .currentLocation {
            Image(systemName: "location.fill")
          }
          regionName
          Image(systemName: "chevron.down")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
      }
      .accessibilityLabel(Text("Region"))
      .accessibilityValue(regionName)
    }
    ToolbarItem(placement: .topBarTrailing) {
      Button("Settings", systemImage: "gearshape") {
        settingsRoute = nil
        isShowingSettings = true
      }
    }
  }
}

/// Screens pushed onto Home.
enum HomeRoute: Hashable {
  /// The day at this index of the forecast.
  case day(Int)
  case regions
  case addRegion
}

#Preview("Sunny day ahead") {
  PreviewHost(.tokyo)
}

#Preview("Several regions") {
  PreviewHost(.severalRegions)
}

#Preview("No sunny day") {
  PreviewHost(.singapore)
}

#Preview("Loading") {
  PreviewHost(.loading)
}

#Preview("Refresh failed") {
  PreviewHost(.refreshFailed)
}

#Preview("No data") {
  PreviewHost(.offline)
}

#Preview("Location denied") {
  PreviewHost(.locationDenied)
}
