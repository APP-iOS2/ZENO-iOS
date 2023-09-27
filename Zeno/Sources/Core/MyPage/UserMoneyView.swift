//
//  UserMoneyView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct UserMoneyView: View {
    var body: some View {
        //        GeometryReader { geometry in
        HStack {
            /// 친구
            VStack {
                Text("10")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                Text("친구")
                    .font(.system(size: 15))
            }
            //                .frame(width: geometry.size.width / 3)
            .frame(width: UIScreen.main.bounds.width/3)
            
            /// 코인
            VStack( spacing: 0) {
                Text("180")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                
                HStack(spacing: 0) {
                    Image("coin")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("코인")
                        .font(.system(size: 15))
                }
            }
            //                .frame(width: geometry.size.width / 3)
            .frame(width: UIScreen.main.bounds.width/3)
            
            /// 지목 받은 제노
            VStack {
                Text("20")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                Text("득표수")
                    .font(.system(size: 15))
            }
            //                .frame(width: geometry.size.width / 3)
            .frame(width: UIScreen.main.bounds.width/3)
            //            }
        }
        .frame(minHeight: 90)
        .background(.purple)
        .foregroundColor(.white)   
    }
}

struct UserMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        UserMoneyView()
    }
}
