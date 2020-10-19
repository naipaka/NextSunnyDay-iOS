//
//  RegionSelectionViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/15.
//

import Combine
import MapKit
import SwiftUI

// MARK: - RegionSelectionViewModelObject
protocol RegionSelectionViewModelObject: ViewModelObject where
    Input: RegionSelectionViewModelInputObject,
    Binding: RegionSelectionViewModelBindingObject,
    Output: RegionSelectionViewModelOutputObject {
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

    private var cancellables: [AnyCancellable] = []

    init(service: LocalSearchService) {
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
            guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }

            let entity = DailyWeatherForecastEntity()
            entity.cityName = self?.binding.selectedCompletion.title ?? ""
            entity.lat = coordinate.latitude
            entity.lon = coordinate.longitude
            DailyWeatherForecastEntity.update(with: entity)
        }
    }
}
