//
//  OnboardingZenoExView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct OnboardingZenoExView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var showNextView: Bool
    
    @State var isExpanded = false
    @State var showtext = false
    
    var body: some View {
        ZStack {
            GeoView(isExpanded: $isExpanded, showtext: $showtext, color: .ggullungColor, showNextView: $showNextView)
            
            ZStack(alignment: .leading) {
                LottieView(lottieFile: "bubbles")
                VStack(alignment: .center) {
                Spacer()
                    Group {
//                        LottieView(lottieFile: "nudgeDevil")
//                            .frame(width: 80, height: 80)
                        VStack(alignment: .center) {
                            Text("누가 나를 선택했는지")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 34))
                                .accessibilityLabel("누가 나를 선택했는지")
                            Text("확인할 수 있어요")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 44))
                                .accessibilityLabel("확인할 수 있어요")
                        }
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .opacity(0.8)
                    }
                    .padding()
                Spacer()
                
                AlarmCellView()
                        .background(
                            Rectangle()
                            .fill(Color(uiColor: .systemGray6))
                            .frame(width: .screenWidth * 0.9 , height: .screenHeight * 0.18)
                            .cornerRadius(10)
                            .padding(10)
                            .shadow(radius: 1)
                        )
                        .offset(y: -40)
                Spacer()
                }
            }
            .opacity(isExpanded ? 1 : 0 )
            .scaleEffect(isExpanded ? 1 : 0)
            .offset(x: showtext ? 0 : .screenWidth)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingZenoExView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingZenoExView(showNextView: .constant(false))
    }
}
