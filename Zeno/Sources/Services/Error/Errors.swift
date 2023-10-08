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
