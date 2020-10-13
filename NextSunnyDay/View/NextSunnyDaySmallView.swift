//
//  NextSunnyDaySmallView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/13.
//

import SwiftUI

struct NextSunnyDaySmallView: View {
    var body: some View {
        ZStack {
            Color(R.color.nextSunnyDayBackgroudColor() ?? .black)
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
                        // TODO: Published from ViewModel
                        Text("東京都港区")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .fixedSize()
                        Spacer()
                            .frame(maxHeight: 8)
                        // TODO: Published from ViewModel
                        Text("12/22 (火)")
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
        .foregroundColor(.white)
        .cornerRadius(30)
    }
}

struct NextSunnyDaySmallView_Previews: PreviewProvider {
    static var contentView: some View {
        NextSunnyDaySmallView()
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
