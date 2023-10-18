//
//  AlarmAlertCheckBtnView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/13/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmAlertCheckBtnView: View {
    @Binding var isPresented: Bool
    
    let imageName: String
    let content: String
    let quantity: Int
    let usingGoods: Int
    let primaryAction1: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 26) {
                LottieView(lottieFile: "shine")
                    .frame(width: .screenWidth * 0.4, height: .screenHeight * 0.1)
                Group {
                    Text("\(content)을 사용하시겠습니까 ?")
                        .multilineTextAlignment(.center)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
                        .offset(y: -20)
                    
                    Divider()
                    
                    Text("잔여 \(content) : \(quantity)개")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 12))
                        .padding(.bottom, -10)
                    
                    Text("사용 : \(usingGoods)개")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 20))
                }
                .foregroundColor(.black)

                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Text("취소")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity)
                    }
                    .initialButtonBackgroundModifier(fontColor: .white, color: .gray)
                    
                    Button {
                        primaryAction1()
                        isPresented = false
                    } label: {
                        Text("사용")
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity)
                    }
                    .initialButtonBackgroundModifier(fontColor: .white, color: .mainColor)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
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
}

struct AlarmAlertCheckBtnView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmAlertCheckBtnView(
            isPresented: .constant(false),
            imageName: "dollar-coin",
            content: "초성확인권",
            quantity: 20,
            usingGoods: 1
        ) {
            // 아아
        }
    }
}
