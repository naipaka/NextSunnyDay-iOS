//
//  HomeView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/09/28.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                VStack {}
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
                .foregroundColor(.gray)
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
