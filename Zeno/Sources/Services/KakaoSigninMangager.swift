//
//  KakaoSigninMangager.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/02.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import SwiftProtobuf
import CoreMedia

class KakaoSignInManager: NormalSignInManager {
    // MARK: - 이메일을 통해 비밀번호를 찾아 반환하는 함수
    func getPassword(email: String) async throws -> String {
        do {
            let target = try await database.collection("User")
                .whereField("email", isEqualTo: email).getDocuments()

            if target.isEmpty {
                return ""
            } else {
                // 어짜피 email은 고유한 존재이므로 문서는 무조건 1개가 걸려옴
                let docData = target.documents[0].data()
                // 비밀번호 추출
                let password = docData["pw"] as? String ?? ""

                return password
            }
        } catch {
            save(value: SignInError.getPassWordError.rawValue, forkey: "error")
            throw(error)
        }
    }
    
    // MARK: - [카카오] 로그인 시도 계정이 Auth에 등록된 사용자인지 확인하는 함수
    func isRegistered(email: String, pw: String, method: String) async throws -> String {
        var newUid: String = ""
            do {
                let target = try await firebaseAuth.createUser(withEmail: email, password: pw)
                newUid = target.user.uid
                return newUid
            } catch {
                do {
                    // 1. 이메일이 이미 firestore에 등록된 이메일인지를 확인한다
                    let emailDup = try await isEmailDuplicated(email: email)

                    // 2. 이미 가입되어 있는 이메일이라면 해당 이메일 + 이메일이 든 document의 pw를 통해 로그인을 시도함
                    if emailDup {
                        // 3. 이미 가입된 이메일 계정의 비밀번호를 가져옴
                        let password = try await getPassword(email: email)

                        // 4. 이미 가입된 계정으로 로그인
                        try await login(with: email, password)

                        // 5. 로그인 상태 변경
                        self.loggedIn = "logIn"
//                        self.save(value: Key.logIn.rawValue, forkey: "state")
//                        self.save(value: LoginMethod.kakao.rawValue, forkey: "loginMethod")
                    }
                } catch {
                    save(value: SignInError.firebaseAuthSignInError.rawValue, forkey: "error")
                    throw(error)
                }
                save(value: SignInError.registerUserError.rawValue, forkey: "error")
                throw(error)
            }
    }
    
    // MARK: - 카카오 로그인
    func kakaoSignIn() async {
         if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                        // 카카오톡이 설치되어 있는지 확인
                         if (UserApi.isKakaoTalkLoginAvailable()) {
                            // 설치되어 있으면 카카오톡 로그인
                            Task {
                                await self.kakaoTalkLogIn()
                            }
                        } else {
                            // 미설치 상태이면 카카오계정 로그인
                            Task {
                                await self.kakaoAccountLogIn()
                            }
                        }
                    } else {
                        self.save(value: SignInError.kakaoInvalidTokenError.rawValue, forkey: "error")
                    }
                } else {
                    self.save(value: SignInError.kakaoAccessTokenError.rawValue, forkey: "error")
                }
            }
        } else {
             if (UserApi.isKakaoTalkLoginAvailable()) {
                // 설치되어 있으면 카카오톡 로그인
                Task {
                    await self.kakaoTalkLogIn()
                }
            } else {
                // 미설치 상태이면 카카오계정 로그인
                Task {
                    await self.kakaoAccountLogIn()
                }
            }
        }
    }
    // MARK: - 카카오톡 로그인 함수
    func kakaoTalkLogIn() async {
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if error != nil {
                self.save(value: SignInError.kakaoTalkSignInError.rawValue, forkey: "error")
             }
            else {
                UserApi.shared.me { user, error in
                    if error != nil {
                        self.save(value: SignInError.getKakaoUserInfoError.rawValue, forkey: "error")
                    } else {
                        Task {
                            do {
                                // 카카오 이메일, Id, 닉네임 값 임시 저장
                                let kakaoEmail = user?.kakaoAccount?.email ?? ""
                                let kakaoId = String(user?.id ?? 0)
                                let kakaoNickName = "user" + UUID().uuidString

                                // firestore에 등록된 유저인지 확인 -> 등록된 유저면 로그인/신규유저면 회원가입하고 uid 획득
                                let isNewby = try await self.isRegistered(email: kakaoEmail, pw: kakaoId, method: "kakao")

                                // 신규 유저인 경우
                                if isNewby != "" {

                                    // 새로운 User 객체 생성
//                                    let newby = User(id: isNewby, name: kakaoNickName, email: kakaoEmail, pw: kakaoId, proImage: "bearWhite", badge: [], friends: [], loginMethod: "kakao", fcmToken: "")

                                    // firestore에 문서 등록
//                                    try await self.uploadUserInfo(userInfo: newby)

                                    // auth 로그인 및 로그인 상태값 변경
                                    try await self.login(with: kakaoEmail, kakaoId)

                                    self.loggedIn = "logIn"
//                                    self.save(value: Newby.newby.rawValue, forkey: "newby")
//                                    self.save(value: Key.logIn.rawValue, forkey: "state")
//                                    self.save(value: LoginMethod.kakao.rawValue, forkey: "loginMethod")
                                }
                            } catch {
                                self.save(value: SignInError.firebaseAuthSignInError.rawValue, forkey: "error")
                                throw(error)
                            }
                        }
                    }
                }
            }
        }
    }
    // MARK: - 카카오계정 로그인 함수
    func kakaoAccountLogIn() async {
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if error != nil {
                self.save(value: SignInError.kakaoAccountSignInError.rawValue, forkey: "error")
            } else {
                UserApi.shared.me { user, error in
                    if error != nil {
                        self.save(value: SignInError.getKakaoUserInfoError.rawValue, forkey: "error")
                    } else {
                        Task {
                            do {
                                // 카카오 이메일, Id, 닉네임 값 임시 저장
                                let kakaoEmail = user?.kakaoAccount?.email ?? ""
                                let kakaoId = String(user?.id ?? 0)
                                let kakaoNickName = "user" + UUID().uuidString

                                // firestore에 등록된 유저인지 확인 -> 등록된 유저면 로그인/신규유저면 회원가입하고 uid 획득
                                let isNewby = try await self.isRegistered(email: kakaoEmail, pw: kakaoId, method: "kakao")

                                // 신규 유저인 경우
//                                if isNewby != "" {
//
//                                    // 새로운 User 객체 생성
//                                    let newby = User(name: <#T##String#>, gender: <#T##String#>, kakaoToken: <#T##String#>, coin: <#T##Int#>, megaphone: <#T##Int#>, showInitial: <#T##Int#>)
//
//                                    // firestore에 문서 등록
//                                    try await self.uploadUserInfo(userInfo: newby)
//
//                                    // auth 로그인 및 로그인 상태값 변경
//                                    try await self.login(with: kakaoEmail, kakaoId)
//
//                                    self.loggedIn = "logIn"
//                                    self.save(value: Newby.newby.rawValue, forkey: "newby")
//                                    self.save(value: Key.logIn.rawValue, forkey: "state")
//                                    self.save(value: LoginMethod.kakao.rawValue, forkey: "loginMethod")
//                                }
                            } catch {
                                self.save(value: SignInError.firebaseAuthSignInError.rawValue, forkey: "error")
                                throw(error)
                            }
                        }
                    }
                }
            }
        }
    }
}
