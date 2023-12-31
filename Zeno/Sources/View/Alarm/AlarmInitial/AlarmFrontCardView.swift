//
//  AlarmFrontView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/11/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmFrontCardView: View {
    @Binding var isFlipped: Bool
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        VStack {
            Image("removedBG_Zeno")
                .resizable()
                .frame(width: .screenWidth * 0.3, height: .screenHeight * 0.15)
            VStack(spacing: 10) {
                Text("초성을 확인하고 싶다면 ?")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 17))
                HStack(spacing: 0) {
                    Text("제노")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 24))
                    Text("를 눌러주세요")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 24))
                }
            }
            .foregroundColor(.white)
            .opacity(0.8)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AngularGradient(gradient: Gradient(colors: [.mainColor, Color.ggullungColor]), center: .topLeading, angle: .degrees(180 + 20)))
                .contentShape(Rectangle())
                .frame(width: .screenWidth * 0.85, height: .screenHeight * 0.63)
                .shadow(radius: 3, x: 5, y: 5)
        )
        .rotationEffect(.degrees(rotation))
        .offset(y: -40)
        .opacity(isFlipped ? 0 : 1)
        .shadow(radius: 3)
        .onAppear {
            withAnimation(.spring().repeatForever(autoreverses: true)) {
                rotation = 2
            }
        }
    }
}

struct AlarmFrontView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmFrontCardView(isFlipped: .constant(false))
    }
}
