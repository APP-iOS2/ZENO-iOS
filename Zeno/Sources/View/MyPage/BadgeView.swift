//
//  BadgeView.swift
//  Zeno
//
//  Created by 박서연 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct BadgeView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    
    var body: some View {
        VStack {
            ForEach(Array(mypageViewModel.itemRatios.enumerated()), id: \.1.key) { index, item in
                Image("")
                Text("\(index + 1)위. \(item.key) (\(String(format: "%.0f", item.value))%)")
                    .lineLimit(2) // 최대 2줄로 제한
            }
        }
        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
        .foregroundColor(.primary)
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView()
            .environmentObject(MypageViewModel())
    }
}
