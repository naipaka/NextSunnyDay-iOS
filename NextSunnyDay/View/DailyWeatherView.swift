//
//  DailyWeatherView.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import SwiftUI

struct DailyWeatherView: View {
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 24)
            VStack {
                Spacer()
                    .frame(height: 14)
                Image(systemName: R.string.systemName.sunMinFill())
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.orange)
                Text("快晴")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
            }
            Spacer()
            Text("12/22 (火)")
                .font(.system(size: 24))
            Spacer()
            VStack {
                Text("11.0℃")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                Spacer()
                    .frame(height: 8)
                Text("2.0℃")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
            Spacer()
                .frame(width: 24)
        }
        .cornerRadius(15)
    }
}

struct DailyWeatherView_Previews: PreviewProvider {
    static var contentView: some View {
        Group {
            DailyWeatherView()
        }
    }

    static var previews: some View {
        Group {
            // 320pt × 568pt (iPhone SE 第1世代)
            contentView
                .previewLayout(.fixed(width: 291.0, height: 82.0))

            // 375pt × 667pt (iPhone 6/6s/7/7s/8/SE 第2世代)
            contentView
                .previewLayout(.fixed(width: 322.0, height: 82.0))

            // 414pt × 736pt (iPhone 6 Plus/6s Plus/7 Plus/8 Plus)
            contentView
                .previewLayout(.fixed(width: 348.0, height: 82.0))

            // 375pt × 812pt (iPhone X/XS/11 Pro)
            contentView
                .previewLayout(.fixed(width: 329.0, height: 82.0))

            // 414pt × 896pt (iPhone XR/XS Max/11/11 Pro Max)
            contentView
                .previewLayout(.fixed(width: 360.0, height: 82.0))
        }
    }
}
