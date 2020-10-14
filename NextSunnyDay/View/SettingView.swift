//
//  SettingView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import SwiftUI

struct SettingView: View {
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
                Text("未設定")
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
                Text("1.0.0")
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
            .onTapGesture {}
            HStack {
                Image(systemName: R.string.systemName.envelopeFill())
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 24, height: 24)
                Spacer()
                    .frame(width: 16)
                Text(R.string.setting.contactUs())
            }
            .onTapGesture {
                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdOw2aW3VP6OYI1jNO4xZtDmkKzJ33otOQLmBxhcKQejuniAQ/viewform?usp=sf_link") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
