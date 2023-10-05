//
//  AuthService.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {
    /// 파이어베이스 Auth의 User
    @Published var userSession: FirebaseAuth.User?
    /// 현재 로그인된 유저
    @Published var currentUser: User?
    private let coolTime: Int = 5
    
    init() {
        Task {
            try await loadUserData()
        }
    }
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    /// 이메일 로그인
    @MainActor
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
	@MainActor
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
                            showInitial: 0
            )
			await uploadUserData(user: user)
			print("🔵 회원가입 성공")
		} catch {
			print("🔴 회원가입 실패. 에러메세지: \(error.localizedDescription)")
		}
	}
	/// 이메일 회원가입 정보 등록하기
    @MainActor
    func uploadUserData(user: User) async {
        self.currentUser = user
        try? await FirebaseManager.shared.create(data: user)
    }
    /// 유저 데이터 가져오기
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = userSession?.uid else { return print("로그인된 유저 없음")}
        print("\(currentUid)")
        self.currentUser = try await UserViewModel.fetchUser(withUid: currentUid)
        print("현재 로그인된 유저: \(currentUser ?? User.dummy[0])")
    }
    /// 로그아웃
    func logout() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
    }
    
    /// 코인 사용 업데이트 함수
    func updateUserCoin(to: Int) async {
        guard let currentUser else { return }
        var coin = currentUser.coin
        self.currentUser?.coin += to
        try? await FirebaseManager.shared.update(data: currentUser, value: \.coin, to: coin)
    }
    /// 초성확인권 사용 업데이트 함수
    func updateUserInitialCheck(to: Int) async {
        guard let currentUser else { return }
        var initialCheck = currentUser.showInitial
        self.currentUser?.showInitial += to
        try? await FirebaseManager.shared.update(data: currentUser, value: \.showInitial, to: initialCheck)
    }
    
    /// 유저가 문제를 다 풀었을 경우, 다 푼 시간을 서버에 등록함
     func updateZenoTimer() async {
         do {
             guard let currentUser = currentUser else { return }
             let zenoStartTime = Date().timeIntervalSince1970
             try await FirebaseManager.shared.update(data: currentUser, value: \.zenoEndAt, to: zenoStartTime + Double(coolTime))
             try await loadUserData()
             print("------------------------")
             print("\(zenoStartTime)")
             print("\(zenoStartTime + Double(coolTime))")
             print("updateZenoTimer !! ")
         } catch {
             print("Error updating zeno timer: \(error)")
         }
     }
     
     /// 유저가 제노를 시작했는지, 안했는지 여부를 판단함 (서버가 맞을지 유저 디포츠가 맞을진 모르겟음)
     func updateUserStartZeno(to: Bool) async {
         do {
             guard let currentUser = currentUser else { return }
             try await FirebaseManager.shared.update(data: currentUser, value: \.startZeno, to: to)
             try await loadUserData()
             print("updateUserStartZeno ")
         } catch {
             print("Error updateStartZeno : \(error)")
         }
     }

     /// 사용자한테 몇초 남았다고 초를 보여주는 함수
     // MARK: 이 함수가 자원 갉아먹고 있음
     func comparingTime() -> Double {
         let currentTime = Date().timeIntervalSince1970
         
         if let currentUser = currentUser,
            let zenoEndAt = currentUser.zenoEndAt {
             return zenoEndAt - currentTime
         } else {
             return 0.0
         }
     }
}

/// static 메서드 모아놓은 extension
extension UserViewModel {
    /// 유저 패치하기
    static func fetchUser(withUid uid: String) async throws -> User {
        let result = await FirebaseManager.shared.read(type: User.self, id: uid)
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}
