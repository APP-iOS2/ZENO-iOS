//
//  KakaoLoginView.swift
//  Zeno
//
//  Created by 박서연 on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct KakaoLoginView: View {
    var body: some View {
        Button {
            print("로그인 버튼 tapped")
        } label: {
            Text("카카오톡으로 시작하기")
                .padding()
                .foregroundColor(.black)
                .background(.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct KakaoLoginView_Previews: PreviewProvider {
    static var previews: some View {
        KakaoLoginView()
    }
}
