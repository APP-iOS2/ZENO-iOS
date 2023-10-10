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
            .background(Color.primary.opacity(0.2))
            .cornerRadius(10)
            .padding(.top, 60)        
    }
}

struct SelectCommunity2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
            .padding(.bottom, 20)
            .foregroundColor(Color.hex("281E44"))
    }
}

struct OpacityAndWhite: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .opacity(0.8)
    }
}

extension View {
    func selectCommunity() -> some View {
        modifier(SelectCommunity())
    }
    
    func opacityAndWhite() -> some View {
        modifier(OpacityAndWhite())
    }
    
    func selectCommunity2() -> some View {
        modifier(SelectCommunity2())
    }
}
