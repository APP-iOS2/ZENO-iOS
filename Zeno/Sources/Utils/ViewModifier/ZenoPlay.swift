//
//  ZenoPlay.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct SelectCommunity: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .foregroundColor(.white)
        // .font(ZenoFontFamily.NanumBarunGothicOTF.light.swiftUIFont(size: 16))
            .frame(width: .screenWidth * 0.9)
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
            .padding(.top, 60)        
    }
}

struct SelectCommunity2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ZenoFontFamily.BMDoHyeonOTF.regular.swiftUIFont(size: 20))
    }
}

extension View {
    func selectCommunity() -> some View {
        modifier(SelectCommunity())
    }
}

extension View {
    func selectCommunity2() -> some View {
        modifier(SelectCommunity2())
    }
}
