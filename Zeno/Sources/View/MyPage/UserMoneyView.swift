//
//  UserMoneyView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct UserMoneyView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        HStack {
            /// 친구가 있어야 하는가 ??
            VStack {
                Text("10")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                Text("친구")
                    .font(.system(size: 15))
            }
            .frame(width: UIScreen.main.bounds.width/3)
            
            /// 코인
            VStack( spacing: 0) {
                Text("\(userViewModel.currentUser?.coin ?? 0)")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                
                HStack(spacing: 0) {
                    Image("pointCoin")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("코인")
                        .font(.system(size: 15))
                }
            }
            .frame(width: UIScreen.main.bounds.width/3)
            
            /// 지목 받은 제노
            VStack {
                Text("\(userViewModel.currentUser?.commInfoList.count ?? 0)")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                Text("득표수")
                    .font(.system(size: 15))
            }
//            .frame(width: UIScreen.main.bounds.width/3)
            .frame(maxWidth: .infinity/3)
        }
        .frame(minHeight: 90)
        .background(ZenoAsset.Assets.mainPurple1.swiftUIColor)
        .foregroundColor(.white)   
    }
}

struct UserMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        UserMoneyView()
            .environmentObject(UserViewModel())
    }
}
