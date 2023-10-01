//
//  LoginViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

class EmailLoginViewModel: ObservableObject {
	@Published var email: String = ""
	@Published var password: String = ""
	
	// 이메일 회원가입할때 쓰는 프로퍼티 들
	@Published var registrationEmail: String = ""
	@Published var registrationPassword: String = ""
	@Published var registrationName: String = ""
	@Published var registrationGender: String = ""
	@Published var registrationDescription: String = ""
	
	func login() async throws {
		try await AuthService.shared.login(email: email, password: password)
	}
	
	func createUser() async throws {
		try await AuthService.shared.createUser(email: registrationEmail,
												passwrod: registrationPassword,
												name: registrationName,
												gender: registrationName,
												description: registrationDescription)
	}
}
