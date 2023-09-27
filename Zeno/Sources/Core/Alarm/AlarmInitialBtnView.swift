//
//  AlarmInitialBtnView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct AlarmInitialBtnView: View {
    // MARK: - Properties
    @Binding var isPresented: Bool
    @Binding var isLackingCoin: Bool
    @Binding var isLackingInitialTicket: Bool
    
    @State private var usingCoin: Bool = false
    @State private var usingInitialTicket: Bool = false
    
    let showInitialViewAction: () -> Void
    let user = User.dummy
    
    // MARK: - View
    var body: some View {
        VStack {
            Text("Zeno 초성 확인하기")
                .bold()
                .padding(.bottom, 50)
            
            Button {
                if user[0].coin >= 60 {
                    usingCoin.toggle()
                } else {
                    isPresented = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        print(" 코인 결제 임")
                        isLackingCoin.toggle()
                    }
                }
            } label: {
                Text("(C)60 선택된 사람의 초성 확인")
                    .initialButtonBackgroundModifier(fontColor: .white, color: .hex("6E5ABD"))
            }
            .alert("코인을 사용하여 확인하시겠습니까 ?", isPresented: $usingCoin) {
                Button(role: .destructive) {
                    showInitialViewAction()
                    isPresented = false
                } label: {
                    Text("확인")
                }
            }
            
            Button {
                if user[0].showInitial > 0 {
                    usingInitialTicket.toggle()
                } else {
                    isPresented = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        print(" 유료 결제 임")
                        isLackingInitialTicket.toggle()
                    }
                }
            } label: {
                Text("(\(user[0].showInitial)번 남음)유료 결제 후 초성 확인")
                    .initialButtonBackgroundModifier(fontColor: .white, color: .hex("6E5ABD"))
            }
            .alert("초성 확인권을 사용하여 확인하시겠습니까 ?", isPresented: $usingInitialTicket) {
                Button(role: .destructive) {
                    showInitialViewAction()
                    isPresented = false
                } label: {
                    Text("확인")
                }
            }
            .padding(.bottom, 20)
            
            Button {
                isPresented = false
            } label: {
                Text("다음에")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
    }
}

struct AlarmInitialBtnView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmInitialBtnView(isPresented: .constant(false), isLackingCoin: .constant(false), isLackingInitialTicket: .constant(false), showInitialViewAction: {})
    }
}
