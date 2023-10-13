//
//  MypageSettingView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MypageSettingView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
//            NavigationLink(destination: UserProfileEdit()) {
//                rowView("프로필 수정")
//            }
//            Divider()
            
            Group {
                linkView("개인정보처리방침", "https://www.pipc.go.kr/np/default/page.do?mCode=H010000000")
                Divider()
                
                linkView("Zeno 문의하기", "https://www.google.com/")
                Divider()
                
                linkView("이용약관", "https://www.google.com/")
                Divider()
                
                linkView("알림 설정", UIApplication.openSettingsURLString)
                Divider()
            }
            
            Button {
                Task {
                    await userViewModel.logoutWithKakao()
                    userViewModel.isNeedLogin = true
                }
            } label: {
                HStack {
                    Text("로그아웃")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            Divider()
            Button {
                Task {
                    await userViewModel.deleteUser()
                    userViewModel.isNeedLogin = true
                }
            } label: {
                Text("회원탈퇴")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
            }
            .padding()
        }
        .foregroundColor(.black)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func rowView(_ label: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
    }
    
    @ViewBuilder
    private func linkView(_ label: String, _ url: String) -> some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                rowView(label)
            }
        }
    }
}

struct MypageSettingView_Previews: PreviewProvider {
    static var previews: some View {
        MypageSettingView()
    }
}
