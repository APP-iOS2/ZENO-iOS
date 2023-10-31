//
//  UserMoneyView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

private class UserMoneyViewModel: ObservableObject {
    @Published var isPruchaseSheet: Bool = false
    
    fileprivate func tappedPruchaseButton() {
        self.isPruchaseSheet = true
    }
}

struct UserMoneyView: View {
    @StateObject private var userMoneyViewModel: UserMoneyViewModel = UserMoneyViewModel()
    @ObservedObject var mypageViewModel: MypageViewModel
//    @State private var isPurchaseSheet: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 3) {
                Button {
                    userMoneyViewModel.tappedPruchaseButton()
                } label: {
                    VStack(spacing: 3) {
                        Text("\(mypageViewModel.userInfo?.showInitial ?? 0)")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                            .fontWeight(.semibold)
                        HStack(spacing: 2) {
                            Text("Z")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 10))
                                .foregroundColor(Color.purple3)
                            Text("확인권")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
                        }
                    }
                }
                .sheet(isPresented: $userMoneyViewModel.isPruchaseSheet, content: {
                    PurchaseView(isShowPaymentSheet: .constant(false))
                        .presentationDetents([.fraction(0.4)])
                        .presentationDragIndicator(.visible)
                })
            }
            .frame(maxWidth: .infinity)
            
            /// 코인
            VStack( spacing: 4) {
                Text("\(mypageViewModel.userInfo?.coin ?? 0)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                    .fontWeight(.semibold)
                Text("코인")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
            }
            .frame(maxWidth: .infinity)
            
            /// 지목 받은 제노
            VStack(spacing: 3) {
                Text("\(mypageViewModel.allAlarmData.count)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                    .fontWeight(.semibold)
                Text("득표수")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
        .foregroundColor(.primary)
    }
}

struct UserMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        UserMoneyView(mypageViewModel: MypageViewModel())
    }
}
