//
//  LocalSearchService.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/15.
//

import Combine
import MapKit

class LocalSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var completer = MKLocalSearchCompleter()

    @Published var searchQuery = ""
    @Published var completions: [MKLocalSearchCompletion] = []

    var cancellable: AnyCancellable?

    override init() {
        super.init()
        completer.delegate = self
        cancellable = $searchQuery.assign(to: \.queryFragment, on: completer)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }
}

extension MKLocalSearchCompletion: Identifiable {}
