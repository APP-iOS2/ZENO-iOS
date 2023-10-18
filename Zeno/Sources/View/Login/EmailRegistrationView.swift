//
//  EmailRegistrationView.swift
//  Zeno
//
//  Created by Muker on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct EmailRegistrationView: View {
    @EnvironmentObject var emailLoginViewModel: EmailLoginViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var isCompleteAlert: Bool = false
    
    var body: some View {
        VStack {
            TextField("이메일을 입력해주세요.", text: $emailLoginViewModel.registrationEmail)
                .modifier(LoginTextFieldModifier())
            // 6자리 이상 입력해야 함
            SecureField("비밀번호를 입력해주세요.", text: $emailLoginViewModel.registrationPassword)
                .modifier(LoginTextFieldModifier())
            TextField("이름을 입력해주세요.", text: $emailLoginViewModel.registrationName)
                .modifier(LoginTextFieldModifier())
//            TextField("성별을 입력해주세요.", text: $emailLoginViewModel.registrationGender)
//                .modifier(LoginTextFieldModifier())
            TextField("한줄소개 입력해주세요.", text: $emailLoginViewModel.registrationDescription)
                .modifier(LoginTextFieldModifier())
            Button {
                Task {
                    do {
                        try await userViewModel.createUser(
                            email: emailLoginViewModel.registrationEmail,
                            passwrod: emailLoginViewModel.registrationPassword,
                            name: emailLoginViewModel.registrationName,
                            gender: emailLoginViewModel.registrationGender,
                            description: emailLoginViewModel.registrationDescription,
                            imageURL: "")
                        
                        emailLoginViewModel.email = emailLoginViewModel.registrationEmail
                        emailLoginViewModel.password = emailLoginViewModel.registrationPassword
                        
                        isCompleteAlert.toggle()
                    } catch {
                        print("회원가입 실패 \(error.localizedDescription)")
                    }
                }
            } label: {
                loginButtonLabel(title: "회원가입",
                                 tintColor: .white,
                                 backgroundColor: ZenoAsset.Assets.mainPurple1.swiftUIColor)
            }
        }
        .alert("회원가입 성공\n뒤로가서 로그인바랍니다.", isPresented: $isCompleteAlert) {
//            Text("회원가입 성공")
        }
    }
}

struct EmailRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailRegistrationView().environmentObject(EmailLoginViewModel())
    }
}
