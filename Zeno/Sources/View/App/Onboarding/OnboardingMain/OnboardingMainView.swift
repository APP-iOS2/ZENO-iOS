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
    
    var body: some View {
        ZStack {
            LottieView(lottieFile: "bubbles")
            VStack {
            Spacer()
                Group {
                    LottieView(lottieFile: "nudgeDevil")
                        .frame(width: 80, height: 80)
                    
                    Text("누가 나를 선택했는지 \n확인할 수 있어요")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 25))
                        .foregroundColor(.gray4)
                }
            Spacer()
            
            AlarmCellView()
                    .background(
                        Rectangle()
                        .fill(Color(uiColor: .systemGray6))
                        .frame(height: .screenHeight * 0.2)
                        .cornerRadius(10)
                        .padding(10)
                        .shadow(radius: 1)
                    )
                    .offset(y: -40)
            Spacer()
                
            }
            OnboardingFirstView(showNextView: $showSview)
            OnboardingSecondView(showNextView: $showTview)
                .modifier(ViewAnimation(isShow: showSview))
            OnboardingLastView(showNextView: $showTview)
                .modifier(ViewAnimation(isShow: showTview))
        }
        .onAppear{
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
