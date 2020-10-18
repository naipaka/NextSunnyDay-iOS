//
//  HomeViewModel.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/12.
//

import Combine

// MARK: - HomeViewModelObject
protocol HomeViewModelObject: ViewModelObject where Input: HomeViewModelInputObject, Binding: HomeViewModelBindingObject, Output: HomeViewModelOutputObject {
    var input: Input { get }
    var binding: Binding { get set }
    var output: Output { get }
}

// MARK: - HomeViewModelInputObject
protocol HomeViewModelInputObject: InputObject {
    var toSettingViewButtonTapped: PassthroughSubject<Void, Never> { get }
}

// MARK: - HomeViewModelBindingObject
protocol HomeViewModelBindingObject: BindingObject {
    var isShowingSettingSheet: Bool { get set }
    var isLoading: Bool { get set }
}

// MARK: - HomeViewModelOutputObject
protocol HomeViewModelOutputObject: OutputObject {
    var forecast: DailyWeatherForecastEntity { get }
}

// MARK: - HomeViewModel
class HomeViewModel: HomeViewModelObject {
    final class Input: HomeViewModelInputObject {
        var toSettingViewButtonTapped: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    }

    final class Binding: HomeViewModelBindingObject {
        @Published var isShowingSettingSheet: Bool = false
        @Published var isLoading: Bool = false
    }

    final class Output: HomeViewModelOutputObject {
        @Published var forecast = DailyWeatherForecastEntity()
    }

    var input: Input

    var binding: Binding

    var output: Output

    private var cancellables: [AnyCancellable] = []

    init() {
        let input = Input()
        let binding = Binding()
        let output = Output()

        // input
        input.toSettingViewButtonTapped.sink(
            receiveValue: { _ in
                binding.isShowingSettingSheet.toggle()
            }
        )
        .store(in: &cancellables)

        self.input = input
        self.binding = binding
        self.output = output
    }
}
