//
//  EmailLoginView.swift
//  Zeno
//
//  Created by Muker on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct EmailLoginView: View {
    @EnvironmentObject var emailLoginViewModel: EmailLoginViewModel
//    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistPage: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Zeno")
                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 60))
                .fontWeight(.black)
                .foregroundStyle(LinearGradient(
                    colors: [Color("MainPurple1"), Color("MainPurple2")],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            Spacer()
            TextField("이메일을 입력해 주세요.", text: $email)
                .modifier(LoginTextFieldModifier())
            SecureField("비밀번호를 입력해 주세요.", text: $password)
                .modifier(LoginTextFieldModifier())
            Button {
                emailLoginViewModel.email = self.email
                emailLoginViewModel.password = self.password
                
                Task {
                    await LoginManager(delegate: emailLoginViewModel).login()
//                    await userViewModel.login(
//                        email: emailLoginViewModel.email,
//                        password: emailLoginViewModel.password
//                    )
                }
            } label: {
                loginButtonLabel(
                    title: "로그인",
                    tintColor: .white,
                    backgroundColor: ZenoAsset.Assets.mainPurple1.swiftUIColor)
            }
            HStack {
                Spacer()
                Button {
                    self.email = ""
                    self.password = ""
                    isRegistPage.toggle()
                } label: {
                    Text("이메일로 회원가입")
                        .font(.caption)
                        .underline()
                }
                .padding(.horizontal)
                .navigationDestination(isPresented: $isRegistPage) {
                    EmailRegistrationView(registEmail: $email, registPassword: $password)
                        .environmentObject(emailLoginViewModel)
                }
            }
            Spacer()
            Spacer()
        }
    }
}

struct EmailLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EmailLoginView()
                .environmentObject(EmailLoginViewModel())
                .environmentObject(UserViewModel())
        }
    }
}
