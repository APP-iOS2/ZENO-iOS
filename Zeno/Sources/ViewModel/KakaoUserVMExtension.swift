//
//  KakaoUserVMExtension.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/10.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

/// 카카오 인증 관련 메서드
extension UserViewModel {
    /// 카카오로 시작하기
    func startWithKakao() async {
        switch self.signStatus {
        case .signIn:
            break
        case .none: // 새로 앱다운, 회원탈퇴했을때
            await loginWithKakao()
        }
    }
    
    /// 카카오로그아웃 && Firebase 로그아웃
    func logoutWithKakao() async {
        print("🦁")
        await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
        print("🦁🦁")
        await self.logout()
        print("🦁🦁🦁")
    }
    
    /// 카카오 로그인 && Firebase 로그인
    private func loginWithKakao() async {
        let (user, isTokened) = await KakaoAuthService.shared.loginUserKakao()
        
        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 없을 경우 신규가입 진행
                print("🦕토큰여부 \(isTokened)")
                if !isTokened {
                    do {
                        // 회원가입 후 바로 로그인.
                        try await self.createUser(email: user.kakaoAccount?.email ?? "",
                                                  passwrod: String(describing: user.id),
                                                  name: user.kakaoAccount?.profile?.nickname ?? "none",
                                                  gender: user.kakaoAccount?.gender?.rawValue ?? "none",
                                                  description: user.kakaoAccount?.legalName ?? "",
                                                  imageURL: user.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? "[none]")
                        
                        await self.login(email: user.kakaoAccount?.email ?? "",
                                         password: String(describing: user.id))
                    } catch let error as NSError {
                        switch AuthErrorCode.Code(rawValue: error.code) {
                        case .emailAlreadyInUse: // 이메일 이미 가입되어 있음 -> 이메일, 비번을 활용하여 재로그인
                            await self.login(email: user.kakaoAccount?.email ?? "",
                                             password: String(describing: user.id))
                            
                        case .invalidEmail: // 이메일 형식이 잘못됨.
                            print("🦕\(user.kakaoAccount?.email ?? "") 이메일 형식이 잘못되었습니다.")
                            
                        default:
                            break
                        }
                    }
                } else {
                    // 토큰정보가 있을 경우 로그인 진행
                    await self.login(email: user.kakaoAccount?.email ?? "",
                                     password: String(describing: user.id))
                }
            }
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            print("🦕ERROR: 카카오톡 유저정보 못가져옴")
        }
    }
    
    /// 카카오 로그인 && Firebase 로그인 ( 회원가입 없음 )
    private func loginWithKakaoNoRegist() async {
        let (user, _) = await KakaoAuthService.shared.loginUserKakao()
        
        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 있을 경우 로그인 진행
                await self.login(email: user.kakaoAccount?.email ?? "",
                                 password: String(describing: user.id))
            }
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            print("ERROR: 카카오톡 유저정보 못가져옴")
        }
    }
}
