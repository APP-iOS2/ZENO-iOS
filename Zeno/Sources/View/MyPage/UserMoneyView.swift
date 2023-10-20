//
//  UserMoneyView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct UserMoneyView: View {
    @EnvironmentObject private var mypageViewModel: MypageViewModel
    @State private var isPurchaseSheet: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 3) {
                Button {
                    print("구매 페이지로 연결!!!")
                    isPurchaseSheet.toggle()
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
                .sheet(isPresented: $isPurchaseSheet, content: {
                    PurchaseView()
                        .presentationDetents([.fraction(0.4)])
                        .presentationDragIndicator(.visible)
                })
            }
            .frame(maxWidth: .infinity/3)
            
            /// 코인
            VStack( spacing: 4) {
                Text("\(mypageViewModel.userInfo?.coin ?? 0)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                    .fontWeight(.semibold)
                Text("코인")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
            }
            .frame(maxWidth: .infinity/3)
            
            /// 지목 받은 제노
            VStack(spacing: 3) {
                Text("\(mypageViewModel.allAlarmData.count)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 15))
                    .fontWeight(.semibold)
                Text("득표수")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 10))
            }
            .frame(maxWidth: .infinity/3)
        }
        .padding(10)
        .foregroundColor(.primary)
    }
}

struct UserMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        UserMoneyView()
            .environmentObject(MypageViewModel())
    }
}
