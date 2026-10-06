//
//  SettingView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import SwiftUI

struct SettingView<T>: View where T: SettingViewModelObject {
  @ObservedObject private var viewModel: T
  @Environment(\.presentationMode) var presentationMode

  init(viewModel: T) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationView {
      Form {
        appSettingSection
        aboutAppSection
      }
      .font(.none)
      .navigationBarTitle("Settings")
      .navigationBarItems(trailing: closeButton)
    }
  }
}

extension SettingView {
  var closeButton: some View {
    Button(
      action: {
        presentationMode.wrappedValue.dismiss()
      },
      label: {
        Image(systemName: "xmark")
          .resizable()
          .frame(width: 20, height: 20, alignment: .center)
          .foregroundColor(Color(.systemGray))
      }
    )
  }

  var appSettingSection: some View {
    Section(header: Text("App Settings")) {
      HStack {
        Image(systemName: "mappin.and.ellipse")
          .resizable()
          .frame(width: 14, height: 14, alignment: .center)
          .fixedSize()
          .foregroundColor(Color(.systemGray))
        Spacer()
          .frame(width: 16)
        Text("Region")
        NavigationLink(
          destination: RegionSelectionView(
            viewModel: RegionSelectionViewModel(service: LocalSearchService()))
        ) {
          Spacer()
          Text(viewModel.output.cityName)
            .foregroundColor(Color(.systemGray))
        }
      }
    }
  }

  var aboutAppSection: some View {
    Section(header: Text("About This App")) {
      HStack {
        Image(systemName: "tag.fill")
          .resizable()
          .frame(width: 14, height: 14, alignment: .center)
          .fixedSize()
          .foregroundColor(Color(.systemGray))
        Spacer()
          .frame(width: 16)
        Text("Version")
        Spacer()
        Text(viewModel.output.version)
          .foregroundColor(Color(.systemGray))
      }
      HStack {
        Image(systemName: "sun.max.fill")
          .resizable()
          .frame(width: 14, height: 14, alignment: .center)
          .fixedSize()
          .foregroundColor(Color(.systemGray))
        Spacer()
          .frame(width: 16)
        Text("About Weather Forecast")
          .lineLimit(1)
          .fixedSize()
        NavigationLink("", destination: AboutWeatherForecastView())
      }
      HStack {
        Image(systemName: "star.fill")
          .resizable()
          .frame(width: 14, height: 14, alignment: .center)
          .fixedSize()
          .foregroundColor(Color(.systemGray))
        Spacer()
          .frame(width: 16)
        Text("Write a Review")
        Button(
          "",
          action: {
            if let url = viewModel.output.reviewURL {
              UIApplication.shared.open(url)
            }
          }
        )
      }
      HStack {
        Image(systemName: "paperplane.fill")
          .resizable()
          .frame(width: 14, height: 14, alignment: .center)
          .fixedSize()
          .foregroundColor(Color(.systemGray))
        Spacer()
          .frame(width: 16)
        Text("Send Feedback")
        Button(
          "",
          action: {
            if let url = viewModel.output.contactUsPageURL {
              UIApplication.shared.open(url)
            }
          }
        )
      }
    }
  }
}

struct SettingView_Previews: PreviewProvider {
  static var previews: some View {
    SettingView(viewModel: MockViewModel())
    SettingView(viewModel: MockViewModel(cityName: "東京都港区"))
    SettingView(viewModel: MockViewModel())
      .environment(\.colorScheme, .dark)
    SettingView(viewModel: MockViewModel(cityName: "東京都港区"))
      .environment(\.colorScheme, .dark)
  }
}

extension SettingView_Previews {
  final class MockViewModel: SettingViewModelObject {
    final class Input: SettingViewModelInputObject {}

    final class Binding: SettingViewModelBindingObject {}

    final class Output: SettingViewModelOutputObject {
      @Published var cityName: String = String(localized: "Not Set")
      @Published var version: String = "-"
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
      output.version =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
      output.reviewURL = nil
      output.contactUsPageURL = nil

      self.input = input
      self.binding = binding
      self.output = output
    }
  }
}
