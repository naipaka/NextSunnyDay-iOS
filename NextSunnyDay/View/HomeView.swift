//
//  HomeView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import SwiftUI

struct HomeView<T>: View where T: HomeViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                if viewModel.output.dataSource.isEmpty {
                    emptyView
                } else {
                    // TODO: NextSunnyDayView and WeeklyForecastView
                }
            }
            .navigationBarTitle(R.string.home.navigationBarTitle())
            .navigationBarItems(trailing: toSettingViewButton)
        }
    }
}

private extension HomeView {
    var toSettingViewButton: some View {
        Button(action: {}, label: {
            Image(systemName: R.string.systemName.gearshapeFill())
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .foregroundColor(.gray)
        })
    }

    var emptyView: some View {
        VStack {
            Image(systemName: R.string.systemName.sunMinFill())
                .resizable()
                .frame(width: 160, height: 160, alignment: .center)
                .padding()
            Text(R.string.home.emptyText())
            Spacer().frame(height: 60)
        }
        .foregroundColor(.gray)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(viewModel: MockViewModel(dataSource: []))
            HomeView(viewModel: MockViewModel(dataSource: [Daily()]))
        }
    }
}

extension HomeView_Previews {
    final class MockViewModel: HomeViewModelObject {
        final class Input: HomeViewModelInputObject {}

        final class Binding: HomeViewModelBindingObject {}

        final class Output: HomeViewModelOutputObject {
            @Published var dataSource: [Daily] = []
        }

        var input: Input

        var binding: Binding

        var output: Output

        init(dataSource: [Daily]) {
            let input = Input()
            let binding = Binding()
            let output = Output()

            output.dataSource = dataSource

            self.input = input
            self.binding = binding
            self.output = output
        }
    }
}
