import Combine
import MapKit
import SwiftUI

// MARK: - RegionSelectionViewModelObject
protocol RegionSelectionViewModelObject: ViewModelObject
where
  Input: RegionSelectionViewModelInputObject,
  Binding: RegionSelectionViewModelBindingObject,
  Output: RegionSelectionViewModelOutputObject
{
  var input: Input { get }
  var binding: Binding { get set }
  var output: Output { get }
}

// MARK: - RegionSelectionViewModelInputObject
protocol RegionSelectionViewModelInputObject: InputObject {
  var regionSelected: PassthroughSubject<Void, Never> { get }
}

// MARK: - RegionSelectionViewModelBindingObject
protocol RegionSelectionViewModelBindingObject: BindingObject {
  var cityName: String { get set }
  var isShowingAlert: Bool { get set }
  var selectedCompletion: MKLocalSearchCompletion { get set }
}

// MARK: - RegionSelectionViewModelOutputObject
protocol RegionSelectionViewModelOutputObject: OutputObject {
  var completions: [MKLocalSearchCompletion] { get }
}

// MARK: - RegionSelectionViewModel
class RegionSelectionViewModel: RegionSelectionViewModelObject {
  final class Input: RegionSelectionViewModelInputObject {
    var regionSelected = PassthroughSubject<Void, Never>()
  }

  final class Binding: RegionSelectionViewModelBindingObject {
    @Published var cityName: String = ""
    @Published var selectedCompletion = MKLocalSearchCompletion()
    @Published var isShowingAlert = false
  }

  final class Output: RegionSelectionViewModelOutputObject {
    @Published var completions: [MKLocalSearchCompletion] = []
  }

  var input: Input

  var binding: Binding

  var output: Output

  @ObservedObject private var localSearchService: LocalSearchService

  private let settings: SettingsStore

  private var cancellables: [AnyCancellable] = []

  init(service: LocalSearchService, settings: SettingsStore = SettingsStore()) {
    self.settings = settings
    input = Input()
    binding = Binding()
    output = Output()

    // LocalSearchService
    localSearchService = service
    localSearchService.$completions
      .assign(to: \.completions, on: output)
      .store(in: &cancellables)

    // input
    input.regionSelected
      .sink(receiveValue: { [weak self] _ in self?.geocoording() })
      .store(in: &cancellables)

    // binding
    binding.$cityName
      .assign(to: \.searchQuery, on: localSearchService)
      .store(in: &cancellables)
  }

  private func geocoording() {
    let searchRequest = MKLocalSearch.Request(completion: binding.selectedCompletion)
    let search = MKLocalSearch(request: searchRequest)
    search.start { [weak self] response, _ in
      guard let self, let coordinate = response?.mapItems.first?.location.coordinate else { return }

      // `HomeViewModel` sees the change in `UserDefaults` and fetches the forecast.
      // The app keeps one region for now, so the new one replaces it.
      settings.regions = [
        .place(
          ForecastLocation(
            name: binding.selectedCompletion.title,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude))
      ]
    }
  }
}
