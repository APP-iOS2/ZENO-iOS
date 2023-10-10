//
//  CardViewVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CardViewVer2: View {
    var currentIndex: Int
    
    private let itemWidth: CGFloat = .screenWidth * 0.51
    private let communities = Community.dummy
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                Rectangle()
                    .frame(width: itemWidth / 8, height: 160)
                    .foregroundColor(.clear)
                
                ForEach(communities.indices, id: \.self) { index in
                    ZenoKFImageView(communities[index])
                        .frame(width: itemWidth, height: .screenHeight * 0.2)
                        .overlay(alignment: .bottomLeading) {
                            Text(communities[index].name)
                                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                                .offset(y: 70)
                                .opacity(currentIndex == index ? 1.0 : 0.3)
                        }
                        .scaleEffect(currentIndex == index ? 0.98 : 0.8)
                }
            }
            .frame(width: CGFloat(Community.dummy.count+1) * itemWidth, height: .screenHeight * 0.38)
        }
        .disabled(true)
    }
}

struct CardViewVer2_Previews: PreviewProvider {
    static var previews: some View {
        CardViewVer2(currentIndex: 0)
    }
}
