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
    
    var body: some View {
        HStack {
            VStack(spacing: 3) {
                Text("\(mypageViewModel.friendIDList?.removeDuplicates().count ?? 0)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
                    .fontWeight(.semibold)
                Text("친구")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
            }
            .frame(maxWidth: .infinity/3)
            
            /// 코인
            VStack( spacing: 4) {
                Text("\(mypageViewModel.userInfo?.coin ?? 0)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
                    .fontWeight(.semibold)
                Text("코인")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
//                HStack(spacing: 0) {
//                    Image("pointCoin")
//                        .resizable()
//                        .frame(width: 17, height: 17)
//                    Text("코인")
//                        .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
//                }
            }
            .frame(maxWidth: .infinity/3)
            
            /// 지목 받은 제노
            VStack(spacing: 3){
                Text("\(mypageViewModel.userInfo?.commInfoList.count ?? 0)")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 20))
                    .fontWeight(.semibold)
                Text("득표수")
                    .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 13))
            }
            .frame(maxWidth: .infinity/3)
        }
        .padding(10)
        .background(Color.purple2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple2, lineWidth: 0.7))
        .foregroundColor(.white)
    }
}

struct UserMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        UserMoneyView()
            .environmentObject(MypageViewModel())
    }
}
