//
//  CardViewVer2.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CardViewVer2: View {
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    private let numberOfItems: Int = 5
    private let itemWidth: CGFloat = 300
    private let peekAmount: CGFloat = -10
    private let dragThreshold: CGFloat = 100
    private let communities = Community.dummy
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: peekAmount) {
                ForEach(communities.indices, id: \.self) { index in
                    Image(communities[index].communityImage)
                        .frame(width: itemWidth, height: 450)
                        .overlay(alignment: .bottomLeading) {
                            Text(communities[index].communityName)
                                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 26))
                                .offset(y: 40)
                                .opacity(self.opacityForText(at: index, in: geometry))
                        }
                        .scaleEffect(self.scaleValueForItem(at: index, in: geometry))
                }
            }
            .offset(x: calculateOffset() + dragOffset)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            dragOffset = value .translation.width
                        }
                    }
                    .onEnded { value in
                        withAnimation(.interactiveSpring()) {
                            finalizePosition(dragValue: value)
                            dragOffset = 0
                        }
                    }
            )
        }
        .padding(.leading)
        .offset(y: 150)
    }

    func calculateOffset() -> CGFloat {
        let totalItemWidth = itemWidth + peekAmount
        let baseOffset = -CGFloat(currentIndex) * totalItemWidth
        return baseOffset
    }
    
    func scaleValueForItem(at index: Int, in geometry: GeometryProxy) -> CGFloat {
        let currentItemOffset = calculateOffset() + dragOffset
        let itemPosition = CGFloat(index) * (itemWidth + peekAmount) + currentItemOffset
        let distanceFromCenter = abs(geometry.size.width / 2 - itemPosition - itemWidth / 2)
        let scale: CGFloat = 0.8 + (0.2 * (1 - min(1, distanceFromCenter / (itemWidth + peekAmount))))
        return scale
    }
    
    func finalizePosition(dragValue: DragGesture.Value) {
        if dragValue.predictedEndTranslation.width > dragThreshold && currentIndex > 0 {
            currentIndex -= 1  // Decrement the current inde
        }
        else if dragValue.predictedEndTranslation.width < -dragThreshold && currentIndex < numberOfItems - 1 {
            currentIndex += 1  // Increment the current index
        }
    }
        
    func opacityForText(at index: Int, in geometry: GeometryProxy) -> Double {
        let currentItemOffset = calculateOffset() + dragOffset
        let itemPosition = CGFloat(index) * (itemWidth + peekAmount) + currentItemOffset + itemWidth / 2
        let distanceFromCenter = abs(geometry.size.width / 2 - itemPosition)
        let threshold: CGFloat = itemWidth / 2
        let opacity = min(1, max(0, (threshold - distanceFromCenter) / threshold))
        return Double(opacity)
    }
}

struct CardViewVer2_Previews: PreviewProvider {
    static var previews: some View {
        CardViewVer2()
    }
}
