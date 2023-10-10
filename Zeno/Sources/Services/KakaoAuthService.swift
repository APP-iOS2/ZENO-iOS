//
//  KakaoAuthService.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

/// 로그인 여부 UserDefault에 저장
enum KakaoSignStatus: String {
    case signIn, signOut, none
    
//    /// 로그인상태 저장.
//    func setStatus() {
//        UserDefaults.standard.set(self.rawValue, forKey: "KakaoSignStatus")
//    }
//
//    /// 상태 가져오기
//    static func getStatus() -> String {
//        return UserDefaults.standard.string(forKey: "KakaoSignStatus") ?? ""
//    }
}

/// 카카오인증 서비스 싱글톤
final class KakaoAuthService {
    static let shared = KakaoAuthService()
    
    private init() { }
    
    private let kakao = KakaoSDKUser.UserApi.shared
    
    /*----------------------------------------------
             로그아웃 버튼을 안 누르면 토큰이 지워지지가 않음.
             토큰 = 여러기기에서 발급 가능.
     ----------------------------------------------*/
    
    /// 카카오 유저 로그인 연동
    /// 유저정보, 토큰활성여부(Bool)
    func loginUserKakao() async -> (KakaoSDKUser.User?, Bool) {
        do {
            let accessToken = try await accessTokenConfirm()  // 토큰 확인
            
            if accessToken != nil {
                return (await loginChkAndFetchUserInfo(), true)
            } else {
                return (await loginChkAndFetchUserInfo(), false)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return (nil, false)        
    }
    
    /// 카카오 유저 로그아웃
    func logoutUserKakao() async {
        let error = await kakaoLogOut()
        if let error {
            // 에러 처리 뭘할지 미정.
            print(error.localizedDescription)
        }
    }
    
    /// 로그인 여부 체크 및 유저정보 가져오기
    private func loginChkAndFetchUserInfo() async -> KakaoSDKUser.User? {
        do {
            let oauthToken = try await kakaoLogin()
            
            if oauthToken != nil {
                let result = await fetchUserInfo()
                
                switch result {
                case .success(let (user, _)):
                    if let user {
                        return user
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}

extension KakaoAuthService {
    /// 카카오로그인
    @MainActor // 메인스레드에서 동작시킴.
    private func kakaoLogin() async throws -> OAuthToken? {
        // 카카오톡 실행 가능 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡을 실행해서 로그인
            return try await withCheckedThrowingContinuation { continuation in
                kakao.loginWithKakaoTalk { oauthToken, error in
                    if let error {
                        print("🐹카톡앱로그인 에러: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("🐹카톡 실행가능")
                        continuation.resume(returning: oauthToken)
                    }
                }
            }
        } else {
            // 카카오톡 계정으로 로그인 (카톡앱실행 X)
            return try await withCheckedThrowingContinuation { continuation in
                // 로그인 힌트부분에 내가 로그인 했었던 이메일 세팅하기 -> UserDefault값 활용.
                kakao.loginWithKakaoAccount(loginHint: "zeno@zeno.com") {(oauthToken, error) in
                    if let error {
                        print("🐹카톡계정로그인 에러 \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("🐹카카오계정 로그인 success.")
                        continuation.resume(returning: oauthToken)
                    }
                }
            }
        }
    }
    
    /// 유저정보 가져오기
    private func fetchUserInfo() async -> Result<(KakaoSDKUser.User?, Error?), Error> {
        return await withCheckedContinuation { continuation in
            kakao.me { user, error in
                if let error {
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success((user, nil)))
                }
            }
        }
    }
    
    /// 기존 로그인 무시하고 재로그인
    private func ignoreLoginAtInKakao() async -> (OAuthToken?, Error?) {
        return await withCheckedContinuation { continuation in
            kakao.loginWithKakaoAccount(prompts: [.Login]) {(oauthToken, error) in
                if let error {
                    print("🐹Failed to ignore existing login \(error.localizedDescription)")
                    continuation.resume(returning: (nil, error))
                } else {
                    print("🐹Re-login successful after ignoring previous login")
                    continuation.resume(returning: (oauthToken, nil))
                }
            }
        }
    }
    
    // MARK: 카카오 계정이 없으신가요??
    /// 카카오계정을 만들고 (가입후) 로그인하기
    private func registAccountAndLoginInKakao() async -> (OAuthToken?, Error?) {
        return await withCheckedContinuation { continuation in
            kakao.loginWithKakaoAccount(prompts: [.Create]) {(oauthToken, error) in
                if let error {
                    print("🐹카카오 계정가입 후 로그인 오류 : \(error)")
                    continuation.resume(returning: (nil, error))
                } else {
                    print("🐹loginWithKakaoAccount() success.")
                    continuation.resume(returning: (oauthToken, nil))
                }
            }
        }
    }
    
    /// 토큰 여부 파악
    /// AccessTokenInfo?, Error?
    private func accessTokenConfirm() async throws -> AccessTokenInfo? {
        // 토큰 유무 파악
        if AuthApi.hasToken() {
            return try await withCheckedThrowingContinuation { continuation in
                kakao.accessTokenInfo { accessToken, error in
                    if let error {
                        print("🐹토큰 정보 조회 실패 : \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("🐹토큰 조회 성공")
//                        _ = KakaoSignStatus.setStatus(.signIn) // 상태 변경 (로그인됨)
                        continuation.resume(returning: accessToken)
                    }
                }
            }
        } else {
            return nil
        }
    }
    
    /// 카카오 로그아웃
    private func kakaoLogOut() async -> Error? {
        return await withCheckedContinuation { continuation in
            kakao.logout {(error) in
                if let error {
                    print("🐹로그아웃 : \(error)")
                    continuation.resume(returning: error)
                } else {
                    print("🐹카카오 로그아웃 완료")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
