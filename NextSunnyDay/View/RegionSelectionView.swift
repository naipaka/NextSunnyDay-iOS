//
//  RegionSelectionView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/15.
//

import Combine
import MapKit
import SwiftUI

struct RegionSelectionView<T>: View where T: RegionSelectionViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            VStack {
                SearchBar(text: $viewModel.binding.cityName)
                List(viewModel.output.completions) { completion in
                    VStack(alignment: .leading) {
                        Text(completion.title)
                        Text(completion.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationBarTitle(Text(R.string.regionSelectionView.selectRegion()))
    }
}

struct RegionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegionSelectionView(viewModel: MockViewModel())
            RegionSelectionView(viewModel: MockViewModel(cityName: "東京都"))
        }
    }
}

extension RegionSelectionView_Previews {
    final class MockViewModel: RegionSelectionViewModelObject {
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

        private var cancellables: [AnyCancellable] = []

        init(cityName: String = "") {
            input = Input()
            binding = Binding()
            output = Output()

            binding.cityName = cityName
        }
    }
}
