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
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: "MainPink1", showNextView: $showNextView)
            
            ZStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("제노에는")
                        .padding(.leading, 40)
                        .padding(.bottom, 10)
                        .opacity(0.8)
                    Text("내가 추가한 친구들만")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 35))
                        .frame(width: .screenWidth)
                        .padding(.bottom, 10)
                    Text("등장해요")
                        .padding(.leading, 40)
                        .opacity(0.8)
                    Spacer()
                    Image("addFriend")
                        .resizable()
                        .frame(width: .screenWidth, height: .screenHeight * 0.1)
                    Spacer()
                }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 33))
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

