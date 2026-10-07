//
//  HomeViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/12.
//

import Combine
import Foundation
import WidgetKit

// MARK: - HomeViewModelObject
protocol HomeViewModelObject: ViewModelObject
where
  Input: HomeViewModelInputObject, Binding: HomeViewModelBindingObject,
  Output: HomeViewModelOutputObject
{
  var input: Input { get }
  var binding: Binding { get set }
  var output: Output { get }
}

// MARK: - HomeViewModelInputObject
protocol HomeViewModelInputObject: InputObject {
  var toSettingViewButtonTapped: PassthroughSubject<Void, Never> { get }
  /// Sent when the app comes to the foreground, including at launch.
  var sceneBecameActive: PassthroughSubject<Void, Never> { get }
}

// MARK: - HomeViewModelBindingObject
protocol HomeViewModelBindingObject: BindingObject {
  var isShowingSettingSheet: Bool { get set }
  var isLoading: Bool { get set }
  var hasError: Bool { get set }
}

// MARK: - HomeViewModelOutputObject
protocol HomeViewModelOutputObject: OutputObject {
  /// The region shown. The app keeps only one for now.
  var region: Region? { get }
  /// The forecast for `region`, or `nil` while there is none.
  var forecast: ForecastSnapshot? { get }
}

extension HomeViewModelOutputObject {
  /// The region name to show, or `nil` when no region is set.
  var regionName: String? {
    switch region?.kind {
    case .place(let location): location.name
    case .currentLocation: forecast?.location.name
    case nil: nil
    }
  }
}

// MARK: - HomeViewModel
class HomeViewModel: HomeViewModelObject {
  final class Input: HomeViewModelInputObject {
    var toSettingViewButtonTapped = PassthroughSubject<Void, Never>()
    var sceneBecameActive = PassthroughSubject<Void, Never>()
  }

  final class Binding: HomeViewModelBindingObject {
    @Published var isShowingSettingSheet: Bool = false
    @Published var isLoading: Bool = false
    @Published var hasError = false
  }

  final class Output: HomeViewModelOutputObject {
    @Published var region: Region?
    @Published var forecast: ForecastSnapshot?
  }

  /// Fetch again once the earliest stored day started more than this long ago.
  private static let maxForecastAge: TimeInterval = 60 * 60 * 24

  var input: Input

  var binding: Binding

  var output: Output

  private let weatherProvider: WeatherProviding
  private let settings: SettingsStore
  private let cache: ForecastCaching
  private var refreshTask: Task<Void, Never>?
  private var cancellables: [AnyCancellable] = []

  init(
    weatherProvider: WeatherProviding, settings: SettingsStore = SettingsStore(),
    cache: ForecastCaching = ForecastCache()
  ) {
    input = Input()
    binding = Binding()
    output = Output()
    self.weatherProvider = weatherProvider
    self.settings = settings
    self.cache = cache
    output.region = settings.regions.first

    // The region is picked on the settings screen and saved to `UserDefaults`.
    NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self, self.settings.regions.first != self.output.region else { return }
        self.refresh()
      }
      .store(in: &cancellables)

    // input
    input.toSettingViewButtonTapped
      .sink(receiveValue: { [weak self] in self?.binding.isShowingSettingSheet.toggle() })
      .store(in: &cancellables)

    // The widget may have refreshed the cache while the app was in the background.
    input.sceneBecameActive
      .sink(receiveValue: { [weak self] in self?.refresh() })
      .store(in: &cancellables)
  }

  deinit {
    refreshTask?.cancel()
  }

  /// Shows the cached forecast for the selected region, then fetches a new one if it is missing
  /// or stale. A refresh already running is replaced.
  private func refresh() {
    refreshTask?.cancel()
    refreshTask = Task { @MainActor [weak self] in
      guard let self else { return }
      let regions = settings.regions
      await cache.removeAll(except: Set(regions.map(\.id)))
      guard let region = regions.first else {
        output.region = nil
        output.forecast = nil
        return
      }
      let cached = await cache.load(for: region.id)
      guard !Task.isCancelled else { return }

      output.region = region
      output.forecast = cached.flatMap { region.matches($0) ? $0 : nil }

      // The current location is resolved with Core Location in #95; until then it can only
      // refresh the place it was last fetched for.
      guard let location = region.location ?? output.forecast?.location else { return }
      let now = Date()
      if output.forecast?.needsRefresh(for: location, now: now, maxAge: Self.maxForecastAge)
        ?? true
      {
        await fetch(location, for: region)
      }
    }
  }

  @MainActor
  private func fetch(_ location: ForecastLocation, for region: Region) async {
    binding.isLoading = true
    defer { binding.isLoading = false }
    do {
      let snapshot = try await weatherProvider.forecast(for: location)
      guard !Task.isCancelled else { return }
      try await cache.save(snapshot, for: region.id)
      output.forecast = snapshot
      WidgetCenter.shared.reloadAllTimelines()
    } catch {
      // A cancelled refresh was replaced by a newer one; it is not an error.
      if !Task.isCancelled {
        binding.hasError = true
      }
    }
  }
}
