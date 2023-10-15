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

extension KakaoSDKUser.Gender {
    func convertToLocalGender() -> Gender {
        switch self {
        case .Male:
            return .male
        case .Female:
            return .female
        }
    }
}

/// 로그인 여부 UserDefault에 저장
enum SignStatus: String {
    case signIn, none
    
    /// 로그인상태 저장.
    func saveStatus() {
        UserDefaults.standard.set(self.rawValue, forKey: "KakaoSignStatus")
    }

    /// 상태 가져오기
    static func getStatus() -> Self {
        if let statusString = UserDefaults.standard.string(forKey: "KakaoSignStatus"),
           let status = SignStatus(rawValue: statusString) {
            return status
        } else {
            return .none
        }
    }
}

/// 카카오인증 서비스 싱글톤
final class KakaoAuthService {
    static let shared = KakaoAuthService()
    
    private init() { }
    
    private let kakao = UserApi.shared
    
    let noneImageURL: String = "https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg"
    
    /// 카카오 유저 로그인 연동
    /// 유저정보, 토큰활성여부(Bool)
    func loginUserKakao() async -> (KakaoSDKUser.User?, Bool) {
        do {
            print("🦕1")
            let accessToken = try await accessTokenConfirm()  // 토큰 확인
            print("🦕토큰 \(String(describing: accessToken))")
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
                    print(#function, err.localizedDescription)
                    return nil
                }
            }
        } catch {
            // 카카오 로그인 재시도 하는 로직 추가예정
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
                kakao.loginWithKakaoAccount {(oauthToken, error) in
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
    func fetchUserInfo() async -> Result<(KakaoSDKUser.User?, Error?), Error> {
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
            print("🦕2")
            return try await withCheckedThrowingContinuation { continuation in
                kakao.accessTokenInfo { accessToken, error in
                    if let error {
                        print("🐹토큰 정보 조회 실패 : \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("🐹토큰 조회 성공")
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
            kakao.logout { error in
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
