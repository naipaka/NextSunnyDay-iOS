import Forecast
import Region
import SunnyDay
import SwiftUI
import Weather

/// The next sunny day, today's hours and ten days for the selected region.
struct HomeView: View {
  let region: SavedRegion

  @Environment(RegionForecast.self) private var regionForecast
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(\.scenePhase) private var scenePhase
  @State private var path: [HomeRoute] = []
  @State private var isShowingSettings = false
  @State private var today = Calendar.current.startOfDay(for: .now)

  /// When any of these change, the forecast is fetched if it is stale.
  private struct RefreshKey: Equatable {
    var region: SavedRegion
    var isActive: Bool
    var day: Date
  }

  var body: some View {
    NavigationStack(path: $path) {
      LayeredScreen(color: headerColor) {
        HomeHeader(
          state: headerState,
          retry: { Task { await regionForecast.refresh(for: region) } })
      } content: {
        content
      }
      .toolbar { toolbar }
      .navigationDestination(for: HomeRoute.self) { route in
        switch route {
        case .day(let index): DayDetailView(initialIndex: index)
        case .region: RegionView()
        }
      }
      .sheet(isPresented: $isShowingSettings) {
        SettingsView()
      }
      .refreshable {
        await regionForecast.refresh(for: region)
      }
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

  private var headerColor: Color {
    switch headerState {
    case .sunny: .orange
    case .noneInRange: Color(.systemGray)
    case .loading, .noData: Color(.systemGray2)
    }
  }

  private var regionName: Text {
    if let name = region.placeName ?? cached?.placeName {
      Text(verbatim: name)
    } else {
      Text("Current Location")
    }
  }

  // MARK: - Content

  @ViewBuilder private var content: some View {
    if let cached {
      if regionForecast.failure != nil {
        RefreshFailedBanner(fetchedAt: cached.fetchedAt) {
          Task { await regionForecast.refresh(for: region) }
        }
      }
      TodayHoursCard(hours: cached.forecast.hourly, today: today)
      DaysCard(days: cached.forecast.daily, level: sunnyLevelSelection.level)
      AttributionFooter(fetchedAt: cached.fetchedAt)
    } else if let failure = regionForecast.failure {
      NoDataCard(failure: failure)
    } else {
      LoadingPlaceholder()
    }
  }

  @ToolbarContentBuilder private var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      NavigationLink(value: HomeRoute.region) {
        HStack(spacing: 6) {
          Image(systemName: "location.fill")
          regionName
        }
        .padding(.horizontal, 4)
      }
    }
    ToolbarItem(placement: .topBarTrailing) {
      Button("Settings", systemImage: "gearshape") {
        isShowingSettings = true
      }
    }
  }
}

/// Screens pushed onto Home.
enum HomeRoute: Hashable {
  /// The day at this index of the forecast.
  case day(Int)
  case region
}

#Preview("Sunny day ahead") {
  PreviewHost(.tokyo)
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
