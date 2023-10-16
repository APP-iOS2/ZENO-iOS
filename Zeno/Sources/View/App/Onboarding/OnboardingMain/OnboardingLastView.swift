//
//  OnboardingLastView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct OnboardingLastView: View {
    @Binding var showNextView: Bool
    
    @State var isExpanded = false
    @State var showtext = false
    
    var body: some View {
        ZStack {
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: "MainColor", text: "Start", shouldToggleExpand: false)
            
            VStack(alignment: .leading) {
                Text("제노를 즐기러 \n가볼까요?")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 25))
            }
            .opacity(isExpanded ? 1 : 0 )
            .scaleEffect(isExpanded ? 1 : 0)
            .offset(x: isExpanded ? 0 : .screenWidth)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingLastView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLastView(showNextView: .constant(false))
    }
}
