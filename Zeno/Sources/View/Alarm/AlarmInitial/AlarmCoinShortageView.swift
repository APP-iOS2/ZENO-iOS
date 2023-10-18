//
//  AlarmCoinShortageView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmCoinShortageView: View {
    @Binding var isPresented: Bool
    var imageTitle: String?
    let title: String
    let content: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "xmark")
                .onTapGesture {
                    isPresented = false
                }
                .foregroundStyle(.black)
                .frame(width: 300, alignment: .trailing)
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .padding(.top, 16)
                .padding(.trailing, 16)
            
            VStack(spacing: 22) {
                if imageTitle != nil {
                    Image(imageTitle!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(.top, 30)
                } else {
                    Image("caution")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(.top, 30)
                }
                Text(title)
                    .foregroundColor(.black)
                    .font(.extraBold(19))
                
                Divider()
                
                VStack {
                    Text(content)
                }
                .font(.regular(13))
                .foregroundColor(.black)
                
                Button {
                    primaryAction()
                    isPresented = false
                } label: {
                    Text(primaryButtonTitle)
                        .font(.bold(14))
                        .frame(maxWidth: .infinity)
                }
                .initialButtonBackgroundModifier(fontColor: .white, color: .hex("6E5ABD"))
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
        .foregroundColor(.black)
            
    }
}

struct AlarmCoinShortageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("알러트 테스트")
            .modifier(
                CashAlertModifier(
                    isPresented: .constant(true),
                    imageTitle: nil,
                    title: "제목",
                    content: "내용",
                    primaryButtonTitle: "버튼 이름",
                    primaryAction: { })
            )
    }
}
