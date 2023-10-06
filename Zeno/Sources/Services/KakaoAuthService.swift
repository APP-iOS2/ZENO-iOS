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
    
    /// 로그인상태 저장.
    func setStatus() {
        // 2개 뭐가 다르지?
        //        UserDefaults.standard.setValue(self.rawValue, forKey: "KakaoSignStatus")
        UserDefaults.standard.set(self.rawValue, forKey: "KakaoSignStatus")
    }
    
    /// 상태 가져오기
    static func getStatus() -> String {
        return UserDefaults.standard.string(forKey: "KakaoSignStatus") ?? ""
    }
}

/// 카카오인증 서비스 싱글톤
final class KakaoAuthService: ObservableObject {
    static let shared = KakaoAuthService()
    
    private init() { }
    
    private let kakao = KakaoSDKUser.UserApi.shared
    
    /*----------------------------------------------
             로그아웃 버튼을 안 누르면 토큰이 지워지지가 않음.
             토큰 = 여러기기에서 발급 가능.
     ----------------------------------------------*/
    
    /// 카카오 유저 로그인 연동
    func loginUserKakao() async -> (KakaoSDKUser.User?, Bool) {
        do {
            print("accesToken start ")
            let (accessToken, _) = try await accessTokenConfirm()  // 토큰 확인
            print("accesToken end ")
            
            if let accessToken {
                return await (loginChkAndFetchUser(), true)
            } else {
                return await (loginChkAndFetchUser(), false)
            }
               
        } catch {
            print(error.localizedDescription)
        }
        return (nil, false)
    }
    
    /// 카카오 유저 로그아웃
    func logoutUserKakao() async {
        do {
           _ = try await kakaoLogOut()
        } catch {
            print(error)
        }
    }
    
    /// 로그인 여부 체크 및 유저정보 가져오기
    private func loginChkAndFetchUser() async -> KakaoSDKUser.User? {
        do {
            let (oauthToken, _) = try await kakaoLogin()
            
            if let oauthToken {
                do {
                    let result = try await fetchUserInfo()

                    switch result {
                    case .success(let (user, _)):
                        if let user {
                            return user
                        }
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
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
    @MainActor
    private func kakaoLogin() async throws -> (OAuthToken?, Error?) {
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
//                        _ = oauthToken
                        continuation.resume(returning: (oauthToken, nil))
                    }
                }
            }
        } else {
            // 카카오톡 계정으로 로그인 (카톡앱실행 X)
            return try await withCheckedThrowingContinuation { continuation in
                kakao.loginWithKakaoAccount(loginHint: "zeno@zeno.com") {(oauthToken, error) in
                    if let error {
                        print("🐹카톡계정로그인 에러 \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("🐹카카오계정 로그인 success.")
                        _ = oauthToken
                        continuation.resume(returning: (oauthToken, nil))
                    }
                }
            }
        }
    }
    
    /// 유저정보 가져오기
    private func fetchUserInfo() async throws -> Result<(KakaoSDKUser.User?, Error?), Error> {
        return try await withCheckedThrowingContinuation { continuation in
            kakao.me { user, error in
                if let error = error {
                    print("🐹카카오유저정보 가져오는중 에러 \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else if let user = user {
                    continuation.resume(returning: .success((user, nil))) // Success case
                } else {
                    // 사용자가 없는 경우에 대한 처리
                    let customError = NSError(domain: "kakakoCom", code: 123, userInfo: nil)
                    continuation.resume(throwing: customError)
                }
            }
        }
    }
    
    /// 기존 로그인 무시하고 재로그인
    private func ignoreLoginAtInKakao() async throws -> (OAuthToken?, Error?) {
        return try await withCheckedThrowingContinuation { continuation in
            kakao.loginWithKakaoAccount(prompts: [.Login]) {(oauthToken, error) in
                if let error {
                    print("🐹기존로그인 무시 실패 \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    print("🐹기존 로그인 무시후 재로그인 성공")
                    continuation.resume(returning: (oauthToken, nil))
                }
            }
        }
    }
    
    // MARK: 카카오 계정이 없으신가요??
    /// 카카오계정을 만들고 (가입후) 로그인하기
    private func registAccountAndLoginInKakao() async throws -> (OAuthToken?, Error?) {
        return try await withCheckedThrowingContinuation { continuation in
            kakao.loginWithKakaoAccount(prompts: [.Create]) {(oauthToken, error) in
                if let error {
                    print("🐹카카오 계정가입 후 로그인 오류 : \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("🐹loginWithKakaoAccount() success.")
                    continuation.resume(returning: (oauthToken, nil))
                }
            }
        }
    }
    
    /// 토큰 여부 파악
    /// AccessTokenInfo?, Error?
    private func accessTokenConfirm() async throws -> (AccessTokenInfo?, Error?) {
        // 토큰 유무 파악
        if AuthApi.hasToken() {
            return try await withCheckedThrowingContinuation { continuation in
                kakao.accessTokenInfo { accessToken, error in
                    if let error {
                        print("🐹토큰 정보 조회 실패 : \(error.localizedDescription)")
//                        continuation.resume(returning: (nil, error))
                        continuation.resume(throwing: error)
                    } else {
                        print("🐹토큰 조회 성공")
//                        _ = KakaoSignStatus.setStatus(.signIn) // 상태 변경 (로그인됨)
                        continuation.resume(returning: (accessToken, nil))
                    }
                }
            }
        } else {
            return (nil, nil)
        }
    }
    
    /// 카카오 로그아웃
    private func kakaoLogOut() async throws -> Error? {
        return try await withCheckedThrowingContinuation { continuation in
            kakao.logout {(error) in
                if let error {
                    print("🐹로그아웃 : \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("🐹카카오 로그아웃 완료")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
