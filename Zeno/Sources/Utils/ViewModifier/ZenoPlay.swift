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
            .font(ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 20))
            .frame(width: .screenWidth )
            //.background(Color.black.opacity(0.8))
    }
}

struct SelectCommunity2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ZenoFontFamily.NanumBarunGothicOTF.bold.swiftUIFont(size: 20))
            .padding(.bottom, 20)
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
