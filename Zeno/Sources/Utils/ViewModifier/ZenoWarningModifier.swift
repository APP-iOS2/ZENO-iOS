//
//  ZenoWarningModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/17.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoWarningModifier: ViewModifier {
    let message: String
    @Binding var isPresented: Bool
    let durring: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ZStack {
                if isPresented {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .blur(radius: isPresented ? 2 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            self.isPresented = false // 외부 영역 터치 시 내려감
                        }
                    ZenoWarningView(
                        message: message,
                        isPresented: $isPresented
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(
                isPresented
                ? .easeInOut(duration: durring)
                : .easeInOut(duration: durring),
                value: isPresented
            )
        }
    }
}

struct ZenoWarningView: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text(message)
                .font(.bold(22))
                .padding(.top, 20)
            Button("확인") {
                isPresented = false
            }
            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
            .foregroundColor(.white)
            .frame(width: .screenWidth * 0.7, height: .screenHeight * 0.07)
            .background(
                Color.mainColor
                    .shadow(radius: 3)
            )
            .cornerRadius(15)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.mainColor)
                .shadow(color: .red, radius: 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.background)
                )
        )
    }
}

extension View {
    func zenoWarning(
        _ message: String,
        isPresented: Binding<Bool>,
        durring: Double = 0.3
    ) -> some View {
        return modifier(
            ZenoWarningModifier(
                message: message,
                isPresented: isPresented,
                durring: durring
            )
        )
    }
}

struct ZenoWarningPreviews: PreviewProvider {
    struct Preview: View {
        @State private var showsAlert = true
        
        var body: some View {
            VStack(spacing: 50) {
                Button {
                    showsAlert = true
                } label: {
                    Text("Alert 보여줘!")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .zenoWarning("존재하지 않는 커뮤니티입니다", isPresented: $showsAlert)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
