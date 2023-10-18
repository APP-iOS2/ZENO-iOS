//
//  LoginViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

final class EmailLoginViewModel: ObservableObject, LoginStatusDelegate {
    func login() async -> Bool {
        do {
            _ = try await Auth.auth().signIn(withEmail: self.email,
                                             password: self.password)
            print("🔵 로그인 성공")
            return true
        } catch let error as NSError {
            switch AuthErrorCode.Code(rawValue: error.code) {
            case .wrongPassword:  // 잘못된 비밀번호
                print("🔴 로그인 실패 : 비밀번호가 잘못되었습니다.")
            case .userTokenExpired: // 사용자 토큰 만료 -> 사용자가 다른 기기에서 계정 비밀번호를 변경했을수도 있음. -> 재로그인 해야함.
                break
            case .tooManyRequests: // Firebase 인증 서버로 비정상적인 횟수만큼 요청이 이루어져 요청을 차단함.
                break
            case .userNotFound: // 사용자 계정을 찾을 수 없음.
                print("🔴 로그인 실패 : 사용자 계정을 찾을 수 없음.")
            case .networkError: // 작업 중 네트워크 오류 발생
                break
            default:
                break
            }
            print("🔴 로그인 실패. 에러메세지: \(error.localizedDescription)")
        }
        return false
    }
    
    /// 로그아웃
    @MainActor
    func logout() async {
        try? Auth.auth().signOut()
//        await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
    }
    
    func memberRemove() async -> Bool {
        return false
    }
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    // 이메일 회원가입할때 쓰는 프로퍼티 들
    @Published var registrationEmail: String = ""
    @Published var registrationPassword: String = ""
    @Published var registrationName: String = ""
    @Published var registrationGender: Gender = .female
    @Published var registrationDescription: String = ""
}
