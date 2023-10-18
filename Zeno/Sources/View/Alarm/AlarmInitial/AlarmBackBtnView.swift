//
//  AlarmBackBtnView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/16/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmBackBtnView: View {
    @Binding var isPresented: Bool
    
    let title: String
    let subTitle: String
    
    let primaryAction1: () -> Void
    
    var body: some View {
        VStack(spacing: 26) {
            Text(title)
                .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                .padding(.top, 30)
                .multilineTextAlignment(.center)
            
            Text(subTitle)
                .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 12))
            
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Text("취소")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 13))
                        .foregroundColor(.white) // 삭제해야할 수도
                        .frame(maxWidth: .infinity)
                }
                .initialButtonBackgroundModifier(fontColor: .red, color: .gray3)
                
                Button {
                    primaryAction1()
                    isPresented = false
                } label: {
                    Text("돌아가기")
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 13))
                        .frame(maxWidth: .infinity)
                }
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

struct AlarmBackBtnView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmBackBtnView(isPresented: .constant(true),
                         title: "초성을 한 번 더 확인하시려면 확인권을 사용해야합니다",
                         subTitle: "돌아가시겠습니까 ?",
                         primaryAction1: {
        })
    }
}
