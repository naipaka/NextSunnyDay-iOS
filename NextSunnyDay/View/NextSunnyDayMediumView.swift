//
//  NextSunnyDayMediumView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/13.
//

import SwiftUI

struct NextSunnyDayMediumView<T>: View where T: NextSunnyDayViewModelObject {
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
                    .frame(idealHeight: 20)
                HStack {
                    Spacer()
                        .frame(maxWidth: 16)
                    Image(systemName: R.string.systemName.sunMinFill())
                    Text(R.string.nextSunnyDay.nextSunnyDay())
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .fixedSize()
                    Spacer()
                }
                Spacer()
                    .frame(maxHeight: 32)
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
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .fixedSize()
                    }
                    Spacer()
                        .frame(maxWidth: 40)
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text(R.string.nextSunnyDay.max())
                                .font(.system(size: 14))
                                .fixedSize()
                            Text(viewModel.output.maxTemperature)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .fixedSize()
                        }
                        Spacer()
                            .frame(maxHeight: 12)
                        VStack(alignment: .leading) {
                            Text(R.string.nextSunnyDay.min())
                                .font(.system(size: 14))
                                .fixedSize()
                            Text(viewModel.output.minTemperature)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .fixedSize()
                        }
                    }
                    Spacer()
                        .frame(maxWidth: 20)
                }
                Spacer()
                    .frame(idealHeight: 20)
            }
        }
        .foregroundColor(.white)
        .clipShape(ContainerRelativeShape())
    }
}

struct NextSunnyDayMediumView_Previews: PreviewProvider {
    static var contentView: some View {
        Group {
            NextSunnyDayMediumView(viewModel: MockViewModel(nextSunnyDay: "12/22 (火)", maxTemperature: "10.0℃", minTemperature: "2.0℃"))
            NextSunnyDayMediumView(viewModel: MockViewModel(backgroundColor: Color(R.color.noSunnyDayBackgroundColor() ?? .gray)))
        }
    }

    static var previews: some View {
        Group {
            // 320pt × 568pt (iPhone SE 第1世代)
            contentView
                .previewLayout(.fixed(width: 291.0, height: 141.0))

            // 375pt × 667pt (iPhone 6/6s/7/7s/8/SE 第2世代)
            contentView
                .previewLayout(.fixed(width: 322.0, height: 148.0))

            // 414pt × 736pt (iPhone 6 Plus/6s Plus/7 Plus/8 Plus)
            contentView
                .previewLayout(.fixed(width: 348.0, height: 159.0))

            // 375pt × 812pt (iPhone X/XS/11 Pro)
            contentView
                .previewLayout(.fixed(width: 329.0, height: 155.0))

            // 414pt × 896pt (iPhone XR/XS Max/11/11 Pro Max)
            contentView
                .previewLayout(.fixed(width: 360.0, height: 169.0))
        }
    }
}

extension NextSunnyDayMediumView_Previews {
    final class MockViewModel: NextSunnyDayViewModelObject {
        final class Input: NextSunnyDayViewModelInputObject {}

        final class Binding: NextSunnyDayViewModelBindingObject {}

        final class Output: NextSunnyDayViewModelOutputObject {
            @Published var backgroundColor = Color(R.color.nextSunnyDayBackgroudColor() ?? .orange)
            @Published var cityName = ""
            @Published var nextSunnyDay = ""
            @Published var maxTemperature = ""
            @Published var minTemperature = ""
        }

        var input: Input

        var binding: Binding

        var output: Output

        init(
            backgroundColor: Color = Color(R.color.nextSunnyDayBackgroudColor() ?? .orange),
            cityName: String = "東京都港区",
            nextSunnyDay: String = R.string.nextSunnyDay.nextWeekOnwards(),
            maxTemperature: String = R.string.nextSunnyDay.hyphen(),
            minTemperature: String = R.string.nextSunnyDay.hyphen()
        ) {
            let input = Input()
            let binding = Binding()
            let output = Output()

            output.cityName = cityName
            output.nextSunnyDay = nextSunnyDay
            output.backgroundColor = backgroundColor
            output.maxTemperature = maxTemperature
            output.minTemperature = minTemperature

            self.input = input
            self.binding = binding
            self.output = output
        }
    }
}
