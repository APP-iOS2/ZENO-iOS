//
//  AlarmInitialAlertView.swift
//  Zeno
//
//  Created by Jisoo HAM on 11/9/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmInitialAlertView: View {
    @Binding var isPresented: Bool
    
    let primaryAction1: () -> Void
    
    var body: some View {
        VStack(spacing: 26) {
            Image(systemName: "alarm.waves.left.and.right")
                .resizable()
                .scaledToFit()
                .frame(width: .screenWidth * 0.15, height: .screenWidth * 0.15)
                .padding(.top, 20)
                .multilineTextAlignment(.center)
            
            Text("초성 확인권 구매 및 사용은 \n 추후 오픈 예정입니다.")
                .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 17))
            
            Button {
                primaryAction1()
            } label: {
                Text("확인")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 14))
                    .frame(maxWidth: .infinity)
                    .initialButtonBackgroundModifier(fontColor: .white, color: .mainColor)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .foregroundColor(.black)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(.blue.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                )
        )
    }
}

struct AlarmInitialAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmInitialAlertView(isPresented: .constant(false), primaryAction1: { })
    }
}
