//
//  KakaoLoginView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct KakaoLoginView: View {
    @EnvironmentObject private var userModel: UserViewModel
    
    var body: some View {
        VStack {
            Button {
                Task {
                    await userModel.startWithKakao()
                }
            } label: {
                Text("카카오톡으로 시작하기")
                    .padding()
                    .foregroundColor(.black)
                    .background(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            Button {
                Task {
                    await userModel.logoutWithKakao()
                }
            } label: {
                Text("로그아웃")
                    .padding()
                    .foregroundColor(.black)
                    .background(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

struct KakaoLoginView_Previews: PreviewProvider {
    static var previews: some View {
        KakaoLoginView()
            .environmentObject(UserViewModel())
    }
}
