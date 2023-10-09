//
//  CardViewVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Kingfisher

struct CardViewVer2: View {
    var currentIndex: Int

    private let numberOfItems: Int = 5
    private let itemWidth: CGFloat = 200
    private let peekAmount: CGFloat = 10
    private let dragThreshold: CGFloat = 70
    private let communities = Community.dummy
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: peekAmount) {
                    ForEach(communities.indices, id: \.self) { index in
                        ZenoKFImageView(communities[index])
                            .frame(width: itemWidth, height: 160)
                            .overlay(alignment: .bottomLeading) {
                                Text(communities[index].name)
                                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                                    .offset(y: 70)
                                    .opacity(self.opacityForText(at: index, in: geometry))
                            }
                            .scaleEffect(self.scaleValueForItem(at: index, in: geometry))
                    }
                }
            }
            .frame(width: CGFloat(numberOfItems) * itemWidth, height: 300)
            .padding(.leading)
        }
        .disabled(true)
    }

    func calculateOffset() -> CGFloat {
        let totalItemWidth = itemWidth + peekAmount
        let baseOffset = -CGFloat(currentIndex-2) * totalItemWidth
        return baseOffset
    }
    
    func scaleValueForItem(at index: Int, in geometry: GeometryProxy) -> CGFloat {
        let currentItemOffset = calculateOffset()
        let itemPosition = CGFloat(index) * (itemWidth + peekAmount) + currentItemOffset
        let distanceFromCenter = abs(geometry.size.width / 2 - itemPosition - itemWidth / 2)
        let scale: CGFloat = 0.8 + (0.2 * (1 - min(1, distanceFromCenter / (itemWidth + peekAmount))))
        return scale
    }
    
    func opacityForText(at index: Int, in geometry: GeometryProxy) -> Double {
        let currentItemOffset = calculateOffset()
        let itemPosition = CGFloat(index) * (itemWidth + peekAmount) + currentItemOffset + itemWidth / 2
        let distanceFromCenter = abs(geometry.size.width / 2 - itemPosition)
        let threshold: CGFloat = itemWidth / 2
        let opacity = min(1, max(0, (threshold - distanceFromCenter) / threshold)+0.3)
        return Double(opacity)
    }
}

struct CardViewVer2_Previews: PreviewProvider {
    static var previews: some View {
        CardViewVer2(currentIndex: 0)
    }
}
