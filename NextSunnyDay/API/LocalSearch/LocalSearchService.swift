//
//  LocalSearchService.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/15.
//

import Combine
import MapKit

class LocalSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var completer: MKLocalSearchCompleter

    @Published var searchQuery = ""
    @Published var completions: [MKLocalSearchCompletion] = []

    var cancellable: AnyCancellable?

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()

        cancellable = $searchQuery.assign(to: \.queryFragment, on: completer)
        completer.delegate = self
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }
}

extension MKLocalSearchCompletion: Identifiable {}
