//
//  SettingView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import SwiftUI

struct SettingView<T>: View where T: SettingViewModelObject {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                VStack {
                    Form {
                        appSettingSection
                        aboutAppSection
                    }
                }
            }
            .navigationBarTitle(R.string.setting.navigationBarTitle())
            .navigationBarItems(trailing: closeButton)
        }
    }
}

extension SettingView {
    var closeButton: some View {
        Button(action: {}, label: {
            Image(systemName: R.string.systemName.xmark())
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .foregroundColor(Color(.systemGray))
        })
    }

    var appSettingSection: some View {
        Section(header: Text(R.string.setting.appSetting())) {
            HStack {
                Image(systemName: R.string.systemName.mappinAndEllipse())
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 24, height: 24)
                Spacer()
                    .frame(width: 16)
                Text(R.string.setting.region())
                Spacer()
                Text(viewModel.output.cityName)
                    .foregroundColor(Color(.systemGray))
            }
            .onTapGesture {}
        }
    }

    var aboutAppSection: some View {
        Section(header: Text(R.string.setting.aboutApp())) {
            HStack {
                Image(systemName: R.string.systemName.appsIphone())
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 24, height: 24)
                Spacer()
                    .frame(width: 16)
                Text(R.string.setting.version())
                Spacer()
                Text(viewModel.output.version)
                    .foregroundColor(Color(.systemGray))
            }
            HStack {
                Image(systemName: R.string.systemName.starFill())
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 24, height: 24)
                Spacer()
                    .frame(width: 16)
                Text(R.string.setting.review())
            }
            .onTapGesture {
                if let url = viewModel.output.reviewURL {
                    UIApplication.shared.open(url)
                }
            }
            HStack {
                Image(systemName: R.string.systemName.envelopeFill())
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 24, height: 24)
                Spacer()
                    .frame(width: 16)
                Text(R.string.setting.contactUs())
            }
            .onTapGesture {
                if let url = viewModel.output.contactUsPageURL {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(viewModel: MockViewModel())
        SettingView(viewModel: MockViewModel(cityName: "東京都港区"))
    }
}

extension SettingView_Previews {
    final class MockViewModel: SettingViewModelObject {
        final class Input: SettingViewModelInputObject {}

        final class Binding: SettingViewModelBindingObject {}

        final class Output: SettingViewModelOutputObject {
            @Published var cityName: String = R.string.setting.unset()
            @Published var version: String = R.string.setting.hyphen()
            @Published var reviewURL: URL?
            @Published var contactUsPageURL: URL?
        }

        var input: Input

        var binding: Binding

        var output: Output

        init(cityName: String = "") {
            let input = Input()
            let binding = Binding()
            let output = Output()

            // output
            if cityName != "" {
                output.cityName = cityName
            }
            output.version = Bundle.main.object(forInfoDictionaryKey: R.string.setting.cfBundleShortVersionString()) as? String ?? R.string.setting.hyphen()
            output.reviewURL = nil
            output.contactUsPageURL = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdOw2aW3VP6OYI1jNO4xZtDmkKzJ33otOQLmBxhcKQejuniAQ/viewform?usp=sf_link")

            self.input = input
            self.binding = binding
            self.output = output
        }
    }
}
