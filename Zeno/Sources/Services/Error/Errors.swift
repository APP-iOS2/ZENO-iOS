//
//  Errors.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/02.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

enum SignInError: String {
    case uploadUserInfoError
    case firebaseAuthSignOutError
    case kakaoSignOutError
    case deleteUserError
    case firebaseAuthSignInError
    case registerUserError
    case emailDuplicateCheckError
    case nickNameDuplicateCheckError
    case firebaseAuthCredentialSignInError
    case getPassWordError
    case registerCheckError
    case kakaoInvalidTokenError
    case kakaoAccessTokenError
    case kakaoTalkSignInError
    case kakaoAccountSignInError
    case getKakaoUserInfoError
    case appleIdentityTokenFetchError
    case serializeTokenStringError
}

/// Firebase Auth 에러코드 모음
enum AuthCreateError: String {
    /// 이메일 주소의 형식이 잘못되었음.
    case FIRAuthErrorCodeInvalidEmail
    /// 해당 이메일 이미 가입되어있음.
    case FIRAuthErrorCodeEmailAlreadyInUse
}
