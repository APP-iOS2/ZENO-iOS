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
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Zeno")
                    .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 60))
                    .fontWeight(.black)
                    .foregroundStyle(LinearGradient(
                        colors: [Color("MainPurple1"), Color("MainPurple2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                Spacer()
                
                Button {
                    print("카카오톡 로그인하기")
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
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
