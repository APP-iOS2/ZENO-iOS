//
//  LoginView.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var emailLoginViewModel: EmailLoginViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("LoginBackground")
                Image("ZenoPng")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .offset(y: -250)
                VStack {
                    ZStack {
                        Image("ZenoBackground")
                    }
                    Spacer()
                    
                    Button {
                        Task {
                            await userViewModel.startWithKakao()
                        }
                    } label: {
                        loginButtonLabel(title: "카카오톡 로그인", tintColor: .white, backgroundColor: .yellow)
                    }
                    
                    NavigationLink {
                        EmailLoginView()
                    } label: {
                        loginButtonLabel(title: "이메일 로그인", tintColor: .black, backgroundColor: Color(.systemGray5))
                    }
                    Spacer().frame(height: 20)
                }
                .offset(y: -30)
            }
            .ignoresSafeArea()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserViewModel())
            .environmentObject(EmailLoginViewModel())
    }
}
