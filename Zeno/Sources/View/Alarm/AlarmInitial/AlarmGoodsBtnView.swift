//
//  AlarmGoodsBtnView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/13/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmGoodsBtnView: View {
    // MARK: - Properties
    @Binding var isPresented: Bool
    
    let content1: String
    let content2: String
    
    let primaryButtonTitle1: String
    let primaryAction1: () -> Void
    
    let primaryButtonTitle2: String
    let primaryAction2: () -> Void
    
    let primaryButtonTitle3: String
    let primaryAction3: () -> Void
    
    // MARK: - View
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Text(content1)
                Text(content2)
            }
            .foregroundColor(.black)
            .padding([.bottom, .top], 50)
            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
            .bold()
            
            Button {
                primaryAction1()
                isPresented = false
            } label: {
                HStack {
                    Image(systemName: "c.circle")
                        .resizable()
                        .frame(width: .screenWidth * 0.06, height: .screenWidth * 0.06)
                    Text(primaryButtonTitle1)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .initialButtonBackgroundModifier(fontColor: .white, color: .hex("FFCD4A"))
            
            Button {
                primaryAction2()
                isPresented = false
            } label: {
                HStack {
                    Image(systemName: "ticket")
                        .resizable()
//                        .scaledToFit()
                        .frame(width: .screenWidth * 0.08, height: .screenWidth * 0.06)
                    
                    Text(primaryButtonTitle2)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 14))
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .initialButtonBackgroundModifier(fontColor: .white, color: .mainColor)
            
            Button {
                primaryAction3()
                isPresented = false
            } label: {
                Text(primaryButtonTitle3)
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 17))
                    .frame(maxWidth: .infinity)
            }
            .initialButtonBackgroundModifier(fontColor: .black, color: .hex("D9D9D9"))
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

struct AlarmGoodsBtnView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmGoodsBtnView(isPresented: .constant(false),
                          content1: "당신을 제노한 사람의 초성을",
                          content2: "확인하시겠습니까 ?",
                          primaryButtonTitle1: "코인 사용",
                          primaryAction1: {},
                          primaryButtonTitle2: "초성 확인권 사용",
                          primaryAction2: {},
                          primaryButtonTitle3: "취소",
                          primaryAction3: {})
    }
}
