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
    
    let primaryAction1: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "xmark.circle")
                .onTapGesture {
                    isPresented = false
                }
                .foregroundStyle(.black)
                .frame(width: 300, alignment: .trailing)
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .padding(.top, 16)
                .padding(.trailing, 16)
            
            VStack(spacing: 26) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 30)
                
                Text("\(content)을 사용하시겠습니까 ?")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Text("취소")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 12))
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
                    .initialButtonBackgroundModifier(fontColor: .white, color: .hex("6E5ABD"))
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
            imageName: "dollar-coin", content: "초성확인권") {
                // 아아
            }
    }
}
