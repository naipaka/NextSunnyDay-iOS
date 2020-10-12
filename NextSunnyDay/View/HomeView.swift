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
        HomeView()
    }
}
