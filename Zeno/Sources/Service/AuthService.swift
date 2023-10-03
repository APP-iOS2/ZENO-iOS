//
//  AuthService.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class AuthService {
	/// 파이어베이스 Auth의 User
	@Published var userSession: FirebaseAuth.User?
	/// 현재 로그인된 유저
	@Published var currentUser: User?
	/// 싱글톤 사용하기
	static let shared = AuthService()
	
	init() {
		Task {
			try await loadUserData()
		}
	}
	/// 이메일 로그인
	func login(email: String, password: String) async throws {
		do {
			let result = try await Auth.auth().signIn(withEmail: email, password: password)
			self.userSession = result.user
			try await loadUserData()
			print("🔵 로그인 성공")
		} catch {
			print("🔴 로그인 실패. 에러메세지: \(error.localizedDescription)")
		}
	}
	/// 이메일 회원가입
	func createUser(email: String, passwrod: String, name: String, gender: String, description: String) async throws {
		do {
			let result = try await Auth.auth().createUser(withEmail: email, password: passwrod)
			self.userSession = result.user
			let user = User(id: result.user.uid,
							name: name,
							gender: gender,
							description: description,
							kakaoToken: "카카오토큰",
							coin: 0,
							megaphone: 0,
							showInitial: 0,
							buddyList: [:])
			await uploadUserData(user: user)
			print("🔵 회원가입 성공")
		} catch {
			print("🔴 회원가입 실패. 에러메세지: \(error.localizedDescription)")
		}
	}
	/// 이메일 회원가입 정보 등록하기
    func uploadUserData(user: User) async {
        self.currentUser = user
        try? await FirebaseManager.shared.create(data: user)
    }
//	func uploadUserData(user: User) async {
//		self.currentUser = user
//		guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
//		try? await Firestore.firestore().collection("Users").document(user.id).setData(encodedUser)
//	}
	
	/// 유저 데이터 가져오기
	func loadUserData() async throws {
		self.userSession = Auth.auth().currentUser
		guard let currentUid = userSession?.uid else { return print("로그인된 유저 없음")}
		print("\(currentUid)")
		self.currentUser = try await AuthService.fetchUser(withUid: currentUid)
		print("현재 로그인된 유저: \(currentUser ?? User.dummy[0])")
	}
	/// 로그아웃
	func logout() {
		try? Auth.auth().signOut()
		self.userSession = nil
		self.currentUser = nil
	}
}

/// static 메서드 모아놓은 extension
extension AuthService {
	/// 유저 패치하기
	static func fetchUser(withUid uid: String) async throws -> User {
        let result = await FirebaseManager.shared.read(type: User.self, id: uid)
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
//		let snapshot = try await Firestore.firestore().collection("Users").document(uid).getDocument()
//		print("유저 패치")
//		return try snapshot.data(as: User.self)
	}
}
