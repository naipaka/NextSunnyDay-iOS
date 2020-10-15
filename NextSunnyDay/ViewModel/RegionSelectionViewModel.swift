//
//  RegionSelectionViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/15.
//

import Combine
import Foundation
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
    var regionSelected: PassthroughSubject<MKLocalSearchCompletion, Never> { get }
}

// MARK: - RegionSelectionViewModelBindingObject
protocol RegionSelectionViewModelBindingObject: BindingObject {
    var cityName: String { get set }
}

// MARK: - RegionSelectionViewModelOutputObject
protocol RegionSelectionViewModelOutputObject: OutputObject {
    var completions: [MKLocalSearchCompletion] { get }
}

// MARK: - RegionSelectionViewModel
class RegionSelectionViewModel: RegionSelectionViewModelObject {
    final class Input: RegionSelectionViewModelInputObject {
        var regionSelected = PassthroughSubject<MKLocalSearchCompletion, Never>()
    }

    final class Binding: RegionSelectionViewModelBindingObject {
        @Published var cityName: String = ""
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
            .sink(receiveValue: { [weak self] in self?.output.completions = $0 })
            .store(in: &cancellables)

        // input
        input.regionSelected
            .sink(
                receiveValue: { [weak self] in
                    self?.geocoording(completion: $0)
                }
            )
            .store(in: &cancellables)

        // binding
        binding.$cityName
            .filter { !$0.isEmpty }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue(label: "RegionSelectedViewModel"))
            .sink(receiveValue: { [weak self] in self?.localSearchService.searchQuery = $0 })
            .store(in: &cancellables)
    }

    private func geocoording(completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }

            DailyWeatherForecastEntity.deleteAll()

            let entity = DailyWeatherForecastEntity()
            entity.cityName = completion.title
            entity.lat = coordinate.latitude
            entity.lon = coordinate.longitude
            DailyWeatherForecastEntity.create(with: entity)
        }
    }
}
