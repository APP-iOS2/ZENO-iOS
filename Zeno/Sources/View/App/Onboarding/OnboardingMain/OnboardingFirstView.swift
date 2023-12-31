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
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: .purple2, showNextView: $showNextView)
            
            ZStack(alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("제노에는")
                        .padding(.horizontal, 30)
                        .padding(.bottom, 4)
                        .opacity(0.9)
                        .accessibilityLabel("제노에는")
                    Text("내가 추가한 친구들만")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 39))
                        .frame(width: .screenWidth)
                        .padding(.bottom, 4)
                        .accessibilityLabel("내가 추가한 친구들만")
                    Text("등장해요")
                        .padding(.horizontal, 30)
                        .opacity(0.9)
                        .accessibilityLabel("등장해요")
                    
                    Spacer()
                    
                    Image("addFriend")
                        .resizable()
                        .cornerRadius(10)
                        .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.086)
                        .padding()
                    
                    Spacer()
                }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 42))
                    .foregroundColor(.white)
                    
                // TODO: 제노 사진 넣기
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
