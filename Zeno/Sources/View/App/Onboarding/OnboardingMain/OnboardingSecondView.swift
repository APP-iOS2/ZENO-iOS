//
//  OnboardingSecondView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct OnboardingSecondView: View {
    @Binding var showNextView: Bool
    @State var isExpanded = false
    @State var showtext = false
    
    var body: some View {
        ZStack {
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: "mainPurple2", showNextView: $showNextView)
            
            ZStack(alignment: .leading) {
                LottieView(lottieFile: "bubbles")
            
                VStack(alignment: .leading) {
                    Text("그룹에 가입해")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 34))
                        .opacity(0.9)
                    Text("더 많은 사람들과")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 34))
                        .opacity(0.9)
                    Text("제노를 즐겨보세요")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 38))
                }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 40))
                    .foregroundColor(.ggullungColor)
                    .padding(40)
            }
            .opacity(isExpanded ? 1 : 0 )
            .scaleEffect(isExpanded ? 1 : 0)
            .offset(x: showtext ? 0 : .screenWidth)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingSecondView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSecondView(showNextView: .constant(false))
    }
}
