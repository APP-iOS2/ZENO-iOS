//
//  MypageSettingView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct MypageSettingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink(destination: UserProfileEdit()) {
                rowView("프로필 수정")
            }
            Divider()
            
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
        }
        .foregroundColor(.black)
        Spacer()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func rowView(_ label: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: "greaterthan")
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
