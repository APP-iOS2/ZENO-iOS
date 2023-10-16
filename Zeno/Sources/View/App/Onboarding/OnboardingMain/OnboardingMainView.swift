//
//  OnboardingMainView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct OnboardingMainView: View {
    @State private var showSview = false
    @State private var showTview = false
    @State private var showFview = false
    
    var body: some View {
        ZStack {
            LottieView(lottieFile: "nudgeDevil")
                .frame(width: 80, height: 80)
                .offset(y: -180) // 브이스택 안에 넣겟습니당 나중에 ㅎ하ㅏ하
            
            Text("누가 나를 선택했는지 \n확인할 수 있어요")
                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 25))
                .offset(y: -100) // ㅎㅎㅎ;;
                .padding(.leading, 8)
            
            OnboardingFirstView(showNextView: $showSview)
            OnboardingSecondView(showNextView: $showTview)
                .modifier(ViewAnimation(isShow: showSview))
            OnboardingLastView(showNextView: $showTview)
                .modifier(ViewAnimation(isShow: showTview))
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
