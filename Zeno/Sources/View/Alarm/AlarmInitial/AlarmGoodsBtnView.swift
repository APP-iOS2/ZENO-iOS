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
    @State private var rotation: CGFloat = 0.0
    
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
            HStack {
                Spacer()
                Button {
                    primaryAction3()
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 17))
                        .foregroundColor(.black)
                }
            }
            
            VStack(alignment: .center) {
                Text(content1)
                Text(content2)
            }
            .foregroundColor(.black)
            .padding([.bottom, .top], 50)
            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
            .bold()
            
            Button {
                primaryAction1()
                isPresented = false
            } label: {
                HStack {
                    Text(primaryButtonTitle1)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 14))
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .initialButtonBackgroundModifier(fontColor: .white, color: .black)
            
            Button {
                primaryAction2()
                isPresented = false
            } label: {
                HStack {
                    Text(primaryButtonTitle2)
                        .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 14))
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(width: 250)
                        .foregroundColor(.purple3)
                        .shadow(radius: 2)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill()
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.mainColor, .mainColor.opacity(0.7), .mainColor.opacity(0.4), .white.opacity(0.4), .white, .white.opacity(0.4), .mainColor.opacity(0.6), .mainColor.opacity(0.7), .mainColor]), startPoint: .top, endPoint: .bottom))
                        .rotationEffect(.degrees(rotation))
                        .mask {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(lineWidth: 4)
                                .frame(width: 250) // 이거 동적으로 바꿀 수 없을까
                        }
                }
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
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
