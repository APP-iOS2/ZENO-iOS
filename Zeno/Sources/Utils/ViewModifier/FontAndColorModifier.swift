//
//  FontAndColorModifier.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/06.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import SwiftUI

struct BlueAndBMfont: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 20))
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundColor(.ggullungColor)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .offset(y: -.screenHeight * 0.2)
    }
}

extension View {
    func blueAndBMfont() -> some View {
        modifier(BlueAndBMfont())
    }
}
