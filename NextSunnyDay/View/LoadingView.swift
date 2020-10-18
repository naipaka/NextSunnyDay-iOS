//
//  LoadingView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/18.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            ProgressView(R.string.loading.loadingLabel())
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
