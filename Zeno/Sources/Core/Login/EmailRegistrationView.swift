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
	
    var body: some View {
		VStack {
			TextField("이메일을 입력해주세요.", text: $emailLoginViewModel.registrationEmail)
				.modifier(LoginTextFieldModifier())
			// 6자리 이상 입력해야 함
			SecureField("비밀번호를 입력해주세요.", text: $emailLoginViewModel.registrationPassword)
				.modifier(LoginTextFieldModifier())
			TextField("이름을 입력해주세요.", text: $emailLoginViewModel.registrationName)
				.modifier(LoginTextFieldModifier())
			TextField("성별을 입력해주세요.", text: $emailLoginViewModel.registrationGender)
				.modifier(LoginTextFieldModifier())
			TextField("한줄소개 입력해주세요.", text: $emailLoginViewModel.registrationDescription)
				.modifier(LoginTextFieldModifier())
			Button {
				Task {
					do {
						try await emailLoginViewModel.createUser()
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
    }
}

struct EmailRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
		EmailRegistrationView().environmentObject(EmailLoginViewModel())
    }
}
