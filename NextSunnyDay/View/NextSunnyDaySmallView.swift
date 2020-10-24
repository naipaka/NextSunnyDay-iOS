//
//  NextSunnyDaySmallView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/13.
//

import SwiftUI

struct NextSunnyDaySmallView<T>: View where T: NextSunnyDayViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            viewModel.output.backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                    .frame(maxHeight: 14)
                HStack {
                    Spacer()
                        .frame(maxWidth: 12)
                    Image(systemName: R.string.systemName.sunMinFill())
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text(R.string.nextSunnyDay.nextSunnyDay())
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .fixedSize()
                    Spacer()
                }
                Spacer()
                    .frame(maxHeight: 20)
                HStack {
                    Spacer()
                        .frame(maxWidth: 20)
                    VStack(alignment: .leading) {
                        Text(viewModel.output.cityName)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .fixedSize()
                        Spacer()
                            .frame(maxHeight: 8)
                        Text(viewModel.output.nextSunnyDay)
                            .font(.system(size: 28))
                            .fontWeight(.bold)
                            .fixedSize()
                    }
                    Spacer()
                        .frame(maxWidth: 20)
                }
                Spacer()
                    .frame(maxHeight: 16)
            }
        }
        .foregroundColor(viewModel.output.textColor)
        .clipShape(ContainerRelativeShape())
    }
}

struct NextSunnyDaySmallView_Previews: PreviewProvider {
    static var contentView: some View {
        Group {
            NextSunnyDaySmallView(viewModel: MockViewModel(nextSunnyDay: "12/22 (火)"))
            NextSunnyDaySmallView(viewModel: MockViewModel(backgroundColor: .noNextSunnyDayBackground))
        }
    }

    static var previews: some View {
        Group {
            // 320pt × 568pt (iPhone SE 第1世代)
            contentView
                .previewLayout(.fixed(width: 141.0, height: 141.0))

            // 375pt × 667pt (iPhone 6/6s/7/7s/8/SE 第2世代)
            contentView
                .previewLayout(.fixed(width: 148.0, height: 148.0))

            // 414pt × 736pt (iPhone 6 Plus/6s Plus/7 Plus/8 Plus)
            contentView
                .previewLayout(.fixed(width: 159.0, height: 159.0))

            // 375pt × 812pt (iPhone X/XS/11 Pro)
            contentView
                .previewLayout(.fixed(width: 155.0, height: 155.0))

            // 414pt × 896pt (iPhone XR/XS Max/11/11 Pro Max)
            contentView
                .previewLayout(.fixed(width: 169.0, height: 169.0))
        }
    }
}

extension NextSunnyDaySmallView_Previews {
    final class MockViewModel: NextSunnyDayViewModelObject {
        final class Input: NextSunnyDayViewModelInputObject {}

        final class Binding: NextSunnyDayViewModelBindingObject {}

        final class Output: NextSunnyDayViewModelOutputObject {
            @Published var backgroundColor: LinearGradient = .nextSunnyDayBackground
            @Published var textColor: Color = .white
            @Published var cityName = ""
            @Published var nextSunnyDay = ""
            @Published var maxTemperature = ""
            @Published var minTemperature = ""
        }

        var input: Input

        var binding: Binding

        var output: Output

        init(
            cityName: String = "東京都港区",
            nextSunnyDay: String = R.string.nextSunnyDay.nextWeekOnwards(),
            backgroundColor: LinearGradient = .nextSunnyDayBackground
        ) {
            let input = Input()
            let binding = Binding()
            let output = Output()

            output.cityName = cityName
            output.nextSunnyDay = nextSunnyDay
            output.backgroundColor = backgroundColor

            self.input = input
            self.binding = binding
            self.output = output
        }
    }
}
