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

/// 유저 데이터 ViewModel
final class UserViewModel: ObservableObject {
    /// 파이어베이스 Auth의 User
    @Published var userSession: FirebaseAuth.User?
    /// 현재 로그인된 유저
    @Published var currentUser: User?
    @Published var kakaoStatus: KakaoSignStatus = .none     // 로그인 여부판단
    
    init() {
//        Task {
//            await loadUserData()
//        }
    }
        
    /// 이메일 로그인
    @MainActor
    func login(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password) // Firebase Auth 에서 인증정보 확인
            self.userSession = result.user
            
            await loadUserData()
            self.kakaoStatus = .signIn
            print("🔵 로그인 성공")
            
        } catch {
            print("🔴 로그인 실패. 에러메세지: \(error.localizedDescription)")
            throw error
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
                            showInitial: 0,
                            buddyList: [:])
            
            await uploadUserData(user: user)
            self.kakaoStatus = .signIn
            
            print("🔵 회원가입 성공")
        } catch {
            print("🔴 회원가입 실패. 에러메세지: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 이메일 회원가입 정보 등록하기
    func uploadUserData(user: User) async {
        self.currentUser = user
        try? await FirebaseManager.shared.create(data: user)
    }
    
    /// 유저 데이터 가져오기
    @MainActor
    func loadUserData() async {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = userSession?.uid else { return print("로그인된 유저 없음") }
        print("CurrentUID : \(currentUid)")
        do {
            self.currentUser = try await UserViewModel.fetchUser(withUid: currentUid)   // 유저 데이터 서버에서 찾아서 가져옴
            
        } catch {
            print("유저데이터로드중 오류 : \(error.localizedDescription)")
        }
//        print("현재 로그인된 유저: \(currentUser ?? User.dummy[0])")
    }
    
    /// 로그아웃
    func logout() async {
        try? Auth.auth().signOut()
        await MainActor.run {
            self.userSession = nil
            self.currentUser = nil
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

extension UserViewModel {
    
    /// 카카오로그아웃 && Firebase 로그아웃
    func logoutWithKakao() async {
        await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
        await self.logout()
    }
    
    /// 카카오 로그인 && Firebase 로그인
    func loginWithKakao() async {
        let (user, isTokened) = await KakaoAuthService.shared.loginUserKakao()
        
        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 없을 경우 신규가입 진행
                print("토큰여부 \(isTokened)")
                if !isTokened {
                    do {
                        try await self.createUser(email: user.kakaoAccount?.email ?? "",
                                                  passwrod: String(describing: user.id),
                                                  name: user.kakaoAccount?.name ?? "none",
                                                  gender: user.kakaoAccount?.gender?.rawValue ?? "none",
                                                  description: user.kakaoAccount?.legalName ?? "")

                    } catch let error as NSError {
                        switch AuthErrorCode.Code(rawValue: error.code) {
                        case .emailAlreadyInUse: // 이메일 이미 가입되어 있음 -> 이메일, 비번을 활용하여 재로그인
                            do {
                                try await self.login(email: user.kakaoAccount?.email ?? "", password: String(describing: user.id))
                            } catch {
                                print("로그인 실패")
                            }
                        case .wrongPassword:     // 비밀번호 오류
                            print("비밀번호 오류\n관리자 문의 바랍니다.")
                        default:
                            break
                        }
                    }
                } else {
                    // 토큰정보가 있을 경우 로그인 진행
                    do {
                        try await self.login(email: user.kakaoAccount?.email ?? "", password: String(describing: user.id))
                    } catch {
                        print(error)
                    }
                }
            }
            
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            print("ERROR: 카카오톡 유저정보 못가져옴")
        }
        
    }
}
