//
//  AlarmInitialBtnView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

extension View {
    func initialButtonBackgroundModifier(fontColor: Color, color: Color) -> some View {
        modifier(InitialButtonBackgroundModifier(color: color, fontColor: fontColor))
    }
}

struct AlarmInitialBtnView: View {
    // MARK: - Properties
    @State private var usingCoin: Bool = false
    @State private var isShowingSheet1: Bool = false
    @State private var usingInitialTicket: Bool = false
    @State private var isShowingSheet2: Bool = false
    @State var isLackingCoin: Bool = false
    @State var isLackingInitialTicket: Bool = false
    
    let user = User.dummy
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            VStack {
                Text("Zeno 초성 확인하기")
                    .bold()
                    .padding(.bottom, 50)
                Button {
                    if user[4].coin >= 60 {
                        usingCoin.toggle()
                    } else {
                        isLackingCoin.toggle()
                    }
                } label: {
                    Text("(C)60 선택된 사람의 초성 확인")
                        .initialButtonBackgroundModifier(fontColor: .white, color: .purple)
                }
                .tossAlert(
                  isPresented: $isLackingCoin,
                  title: "코인이 부족합니다.",
                  primaryButtonTitle: "확인",
                  primaryAction: { /* 송금 로직 */ }
                )
                .alert("코인을 사용하여 확인하시겠습니까 ?", isPresented: $usingCoin) {
                    Button(role: .destructive) {
                        isShowingSheet1.toggle()
                    } label: {
                        Text("확인")
                    }
                }
                .navigationDestination(isPresented: $isShowingSheet1, destination: {
                    AlarmInitialView()
                })
                
                Button {
                    if user[4].showInitial > 0 {
                        usingInitialTicket.toggle()
                    } else {
                        isLackingInitialTicket.toggle()
                    }
                } label: {
                    Text("(2번 남음)유료 결제 후 초성 확인")
                        .initialButtonBackgroundModifier(fontColor: .white, color: .purple)
                }
                .tossAlert(
                  isPresented: $isLackingInitialTicket,
                  title: "초성확인권이 부족합니다.",
                  primaryButtonTitle: "확인",
                  primaryAction: { /* 송금 로직 */ }
                )
                .alert("초성 확인권을 사용하여 확인하시겠습니까 ?", isPresented: $usingInitialTicket) {
                    Button(role: .destructive) {
                        isShowingSheet2.toggle()
                    } label: {
                        Text("확인")
                    }
                }
                .navigationDestination(isPresented: $isShowingSheet2, destination: {
                    AlarmInitialView()
                })
                .padding(.bottom, 20)
                Button {
                } label: {
                    Text("다음에")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
            }
        }
    }
}

struct AlarmInitialBtnView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmInitialBtnView()
    }
}
