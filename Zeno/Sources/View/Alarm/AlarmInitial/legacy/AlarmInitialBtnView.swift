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
    @EnvironmentObject var userVM: UserViewModel
    @Binding var isPresented: Bool
    @Binding var isLackingCoin: Bool
    @Binding var isLackingInitialTicket: Bool
    
    @State private var usingCoin: Bool = false
    @State private var usingInitialTicket: Bool = false
    
    let showInitialViewAction: () -> Void
    
    // MARK: - View
    var body: some View {
        VStack {
            Text("Zeno 초성 확인하기")
                .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 15))
                .bold()
                .padding(.bottom, 50)
            
            Button {
                if userVM.currentUser?.coin ?? 0 >= 60 {
                    usingCoin.toggle()
                } else {
                    isPresented = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        print(" 코인 결제 임")
                        isLackingCoin.toggle()
                    }
                }
            } label: {
                Text("코인으로 초성 확인")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                    .frame(width: .screenWidth * 0.5)
                    .initialButtonBackgroundModifier(fontColor: .white, color: .hex("6E5ABD"))
            }
            .alert(isPresented: $usingCoin) {
                let firstButton = Alert.Button.destructive(Text("취소")) {
                }
                let secondButton = Alert.Button.default(Text("확인")) {
                    showInitialViewAction()
                    Task {
                        await userVM.updateUserCoin(to: -60)
                    }
                    isPresented = false
                }
                return Alert(title: Text("(C)60을 사용하여 확인하시겠습니까 ?"),
                             message: Text("보유 코인:\(userVM.currentUser?.coin ?? 0)\n결제 후 잔여 코인: \((userVM.currentUser?.coin ?? 0) - 60)"),
                             primaryButton: firstButton, secondaryButton: secondButton)
            }
            
            Button {
                if userVM.currentUser?.showInitial ?? 0 > 0 {
                    usingInitialTicket.toggle()
                } else {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        print(" 유료 결제 임")
                        isLackingInitialTicket.toggle()
                    }
                }
            } label: {
                Text("초성 확인권으로 초성 확인")
                    .frame(width: .screenWidth * 0.5)
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
                    .initialButtonBackgroundModifier(fontColor: .white, color: .hex("6E5ABD"))
            }
            .alert(isPresented: $usingInitialTicket) {
                let firstButton = Alert.Button.destructive(Text("취소")) {
                }
                let secondButton = Alert.Button.default(Text("확인")) {
                    showInitialViewAction()
                    Task {
                        await userVM.updateUserInitialCheck(to: -1)
                    }
                    isPresented = false
                }
                return Alert(title: Text("초성 확인권 1개를 사용하여 확인하시겠습니까 ?"),
                             message: Text("초성 확인권:\(userVM.currentUser?.showInitial ?? 0)\n결제 후 잔여 확인권: \((userVM.currentUser?.showInitial ?? 0) - 1)"),
                             primaryButton: firstButton, secondaryButton: secondButton)
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
            .environmentObject(UserViewModel())
    }
}
