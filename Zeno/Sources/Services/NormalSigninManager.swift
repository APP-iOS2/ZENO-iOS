//
//  NormalSigninManager.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/02.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

class NormalSignInManager: SignInManager {
    // MARK: - Functions
    
    // MARK: - FirebaseAuth 로그인 함수
    func login(with email: String, _ password: String) async throws {
        do {
            try await firebaseAuth.signIn(withEmail: email, password: password)
            self.save(value: email, forkey: "loginMethod") // 여기 문제 생길 수 있음
        } catch {
            self.save(value: SignInError.firebaseAuthSignInError.rawValue, forkey: "error")
            throw(error)
        }
    }
    
    // MARK: - 신규회원 생성
    func register(email: String, pw: String, name: String) async throws {
        do {
            // Auth에 유저등록
            let target = try await firebaseAuth.createUser(withEmail: email, password: pw).user

            // 신규회원 객체 생성
            // let newby = User

            // firestore에 신규회원 등록
            // try await uploadUserInfo(userInfo: newby)

        } catch {
            self.save(value: SignInError.registerUserError.rawValue, forkey: "error")
            throw(error)
        }
    }
    
    // MARK: - 이메일 중복확인을 해주는 함수
    func isEmailDuplicated(email: String) async throws -> Bool {
        do {
            let target = try await database.collection("User")
                .whereField("email", isEqualTo: email).getDocuments()

            if target.isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            self.save(value: SignInError.emailDuplicateCheckError.rawValue, forkey: "error")
            throw(error)
        }
    }
    
    // MARK: - 닉네임 중복확인을 해주는 함수
    func isNicknameDuplicated(nickName: String) async throws -> Bool {
        do {
            let target = try await database.collection("User")
                .whereField("name", isEqualTo: nickName).getDocuments()

            if target.isEmpty {
                return false // 중복되지 않은 닉네임
            } else {
                return true // 중복된 닉네임
            }
        } catch {
            self.save(value: SignInError.nickNameDuplicateCheckError.rawValue, forkey: "error")
            throw(error)
        }
    }
}
