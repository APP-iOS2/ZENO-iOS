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
    let title: String
    let content: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    
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
            
            VStack(spacing: 22) {
                Image("caution")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .padding(.top, 30)
                
                Text(title)
                    .font(.title2)
                    .bold()
                
                Divider()
                
                VStack {
                    Text(content)
                }
                .bold()
                
                Button {
                    primaryAction()
                    isPresented = false
                } label: {
                    Text(primaryButtonTitle)
                        .font(.title3)
                        .bold()
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
    }
}

struct AlarmCoinShortageView_Previews: PreviewProvider {
    static var previews: some View {
      Text("알러트 테스트")
        .modifier(
          CashAlertModifier(
            isPresented: .constant(true),
            title: "제목",
            content: "내용",
            primaryButtonTitle: "버튼 이름",
            primaryAction: { })
        )
    }
}
