//
//  OnboardingFirstView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct OnboardingFirstView: View {
    @Binding var showNextView: Bool
    
    @State var isExpanded = false
    @State var showtext = false
    
    var body: some View {
        ZStack {
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: "MainColor", showNextView: $showNextView)
            
            ZStack(alignment: .leading) {
                LottieView(lottieFile: "bubbles")
                Text("제노에는 내가 추가한 \n친구들만 등장해요")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 25))
                    .foregroundColor(.white)
                    .padding(40)
            }
            .opacity(isExpanded ? 1 : 0 )
            .scaleEffect(isExpanded ? 1 : 0)
            .offset(x: showtext ? 0 : .screenWidth)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingFirstView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFirstView(showNextView: .constant(false))
    }
}


