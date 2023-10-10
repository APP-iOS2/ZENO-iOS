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

/*
    1. 앱을 새로 다운받고 실행.
        = Status.none상태확인 -> 카카오로그인 -> 토큰 발행 -> 파베회원가입 -> 파베로그인인증 -> User정보FireStore에 저장 -> Status.signIn -> 메인탭전환 -> Status.signIn상태 UserDefault저장
    2. (이미 다운하고 로그인까지 한)앱을 종료 후 다시 실행
        로그아웃안함. = Status.signIn상태 -> 메인탭전환
        로그아웃함.  = Status.signOut상태 -> 1번 방법 재실행인데 파베회원가입, User정보저장을 생략한다. -> Status.signIn -> 메인탭전환
    3. 회원탈퇴 후 재 가입 (회원탈퇴시 Status.none으로 변경 후 UserDefault에 저장.)
        = 회원탈퇴시 Status.none으로 상태변경되어 있어야함.  -> 1번 방법을 재실행함.
    4. 로그아웃, 회원탈퇴 안하고 앱 삭제 후 다시 깔아서 실행. => ( Status값이 none인 상태, DB User에 정보가 남아있는 상태, 카카오토큰이 있는 상태, 파베Auth가 남아있는 상태 )
        = Status.none인 경우확인 -> 1번 재실행
 
    정리하면...
     - Status상태를 먼저 확인 후 그 다음 로직 진행.
     - Status.none인 상태면 1번 방법을 실행하면 됨. -> 이때 파베회원가입을 하게 될때 이메일 중복이 뜨면 바로 로그인을 해주면 되고, 나머지 경우는 그대로 진행.
     - Status.signIn 상태면 토큰확인만 다시 해주고 바로 메인탭 전환시키면 됨.
     - Status.signOut 상태면 1번방법 실행하되 파베회원가입, User정보저장만 생략. 파베관련해서는 UserViewModel.login만 실행.
     - UserViewmodel의 login메서드에서 로그인되었을 때 Status.signIn상태로 변경 후 UserDefault에 저장.
     - UserViewmodel의 logout메서드에서 Status.signOut상태로 변경 후 저장.
     - 회원탈퇴 메서드에서는 Status.none상태로 변경 후 저장.
 
    서연님이랑 테스트 할거 23.10.10
    1. User에 정보 안들어가는거 확인
    2. 실기기에서 카톡앱으로 해보기. ( 로그인부터 로그아웃 전부다 )
 */

/// 카카오인증 서비스 싱글톤
final class KakaoAuthService {
    static let shared = KakaoAuthService()
    
    private init() { }
    
    private let kakao = UserApi.shared
    
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
                kakao.loginWithKakaoAccount(prompts: [.SelectAccount], loginHint: "swjtwin@nate.com") {(oauthToken, error) in
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
