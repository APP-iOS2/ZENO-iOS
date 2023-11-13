//
//  ZenoErrorHandleModifier.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/28.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ZenoErrorHandleModifier: ViewModifier {
    let error: Error
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
                    ZenoErrorHandleView(
                        error: error,
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
    
    init(error: Error, isPresented: Binding<Bool>, durring: Double = 0.3) {
        self.error = error
        self._isPresented = isPresented
        self.durring = durring
    }
}

struct ZenoErrorHandleView: View {
    let error: Error
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            // TODO: Error 안내 메세지로 변경
            Text(error.localizedDescription)
                .font(.regular(16))
                .padding(.top, 25)
            Button {
                isPresented = false
            } label: {
                Text("확인")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 15))
                    .foregroundColor(.white)
                    .frame(width: .screenWidth * 0.7, height: .screenHeight * 0.05)
                    .background(
                        Color.mainColor
                            .shadow(radius: 3)
                    )
                    .cornerRadius(15)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .frame(width: .screenWidth * 0.8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.mainColor)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.background)
                )
        )
    }
}

extension View {
    func zenoErrorHandling(
        _ error: Error,
        isPresented: Binding<Bool>,
        durrring: Double = 0.3
    ) -> some View {
        return modifier(
            ZenoErrorHandleModifier(
                error: error,
                isPresented: isPresented
            )
        )
    }
}

struct ZenoErrorHandleModifier_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var isPresented = true
        
        var body: some View {
            VStack {
                
            }
            .zenoErrorHandling(FirebaseError.documentToData, isPresented: $isPresented)
        }
    }
    static var previews: some View {
        Preview()
    }
}
