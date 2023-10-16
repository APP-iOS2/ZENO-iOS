//
//  OnboardingMainView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

// 회원 가입 하고 나서, 딱 한번

struct OnboardingMainView: View {
    @State private var showSview = false
    @State private var showTview = false
    @State private var showFview = false
    @State private var showZview = false
    
    // '제노'는 익명으로 마음을 전달하는 퀴즈에요!

    var body: some View {
        ZStack {
            ZStack {
                LottieView(lottieFile: "bubbles")
              
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text("제노는")
                        .font(.bold(38))
                    Text("익명으로")
                        .font(.bold(35))
                    Text("마음을 전달하는")
                        .font(.bold(33))
                    Text("퀴즈에요")
                        .font(.bold(38))
                    
                    Spacer()
                    Spacer()
                    LottieView(lottieFile: "beforeZeno")
                        .frame(width: .screenWidth * 0.4, height: .screenHeight * 0.2)
                        .offset(x: -100, y: 70)
                }
            }
            .foregroundColor(.ggullungColor)
            .opacity(0.9)
            .font(.bold(35))
         
            OnboardingZenoExView(showNextView: $showZview)
            OnboardingFirstView(showNextView: $showSview)
                .modifier(ViewAnimation(isShow: showZview))
            OnboardingSecondView(showNextView: $showTview)
                .modifier(ViewAnimation(isShow: showSview))
            OnboardingLastView(showNextView: $showTview)
                .modifier(ViewAnimation(isShow: showTview))
        }
        .onAppear {
            HapticManager.instance.impact(style: .rigid)
        }
    }
}

struct OnboardingMainView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingMainView()
    }
}

struct ViewAnimation: ViewModifier {
    var isShow: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShow ? 0 : 200)
            .scaleEffect(isShow ? 1 : 0, anchor: .bottomTrailing)
            .animation(.spring(), value: isShow)
    }
}
