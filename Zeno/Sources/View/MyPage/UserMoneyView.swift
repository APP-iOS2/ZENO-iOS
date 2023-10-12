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
            /// 친구가 있어야 하는가 ??
            VStack {
                Text("\(mypageViewModel.friendIDList?.removeDuplicates().count ?? 0)")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                Text("친구")
                    .font(.system(size: 15))
            }
            .frame(maxWidth: .infinity/3)
            
            /// 코인
            VStack( spacing: 0) {
                Text("\(mypageViewModel.userInfo?.coin ?? 0)")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                
                HStack(spacing: 0) {
                    Image("pointCoin")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("코인")
                        .font(.system(size: 15))
                }
            }
            .frame(maxWidth: .infinity/3)
//            .frame(width: UIScreen.main.bounds.width/3)
            
            /// 지목 받은 제노
            VStack {
                Text("\(mypageViewModel.userInfo?.commInfoList.count ?? 0)")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                Text("득표수")
                    .font(.system(size: 15))
            }
            .frame(maxWidth: .infinity/3)
        }
        .padding(10)
        .background(ZenoAsset.Assets.mainPurple1.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundColor(.white)
        .padding()
    }
}

struct UserMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        UserMoneyView()
            .environmentObject(MypageViewModel())
    }
}
