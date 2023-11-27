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
/// 카카오로그인서비스로 변경
extension UserViewModel {
    /// 카카오로 시작하기
    func startWithKakao() async -> Bool {
        if SignStatusObserved.shared.signStatus == .unSign {
            return await loginWithKakao()
        } else {
            return true
        }
    }
    
    /// 카카오 로그인 && Firebase 로그인
    private func loginWithKakao() async -> Bool {
        let (user, isTokened) = await KakaoAuthService.shared.loginUserKakao()

        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 없을 경우 신규가입 진행
                print("✔️토큰여부 \(isTokened)")
                if !isTokened {
                    do {
                        // 1. https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg  // 빈거
                        // 2. https://k.kakaocdn.net/dn/ciQMBt/btsycuaeWmV/lv5RtAsudfPkXl6u8rcmsK/img_640x640.jpg  // 뭔가 넣은거
                        // 3. https://k.kakaocdn.net/dn/dpk9l1/btqmGhA2lKL/Oz0wDuJn1YV2DIn92f6DVK/img_640x640.jpg  // 빈거
                        // KakaoAuthService.shared.noneImageURL에 (빈이미지 URL) 상수값으로 담아둠. 23.10.15
                        // 회원가입 후 바로 로그인.
                        try await self.createUser(email: user.kakaoAccount?.email ?? "",
                                                  passwrod: String(describing: user.id),
                                                  name: user.kakaoAccount?.profile?.nickname ?? "",
                                                  gender: user.kakaoAccount?.gender?.convertToLocalGender() ?? .unknown,
                                                  description: "",
                                                  imageURL: user.kakaoAccount?.profile?.profileImageUrl?.absoluteString)
                        print("✔️회원가입 완료")
                        await self.login(email: user.kakaoAccount?.email ?? "",
                                         password: String(describing: user.id))
                        
                        // 로그인 후에 메인탭 진입전 닉네임변경창 열렸었는지 판단. false => 닉넴 변경 안함,  true => 닉넴 변경까지 완료함.
                        UserDefaults.standard.set(false, forKey: "nickNameChanged") // 닉네임 변경창 열렸었는지 판단. 여기서 초기설정해줌.
                        
                        await MainActor.run {
                            print("✔️isNickNameRegistViewPop true")
                            self.isNickNameRegistViewPop = true // TabBarView에서 Sheet 오픈
                        }
                        
                        return true
                    } catch let error as NSError {
                        switch AuthErrorCode.Code(rawValue: error.code) {
                        case .emailAlreadyInUse: // 이메일 이미 가입되어 있음 -> 이메일, 비번을 활용하여 재로그인
                            print("✔️여기여기!!")
                            UserDefaults.standard.set(true, forKey: "nickNameChanged") // 로그인 = 이미 회원가입이 되어있음으로 인식.
                            await MainActor.run {
                                isNickNameRegistViewPop = false // 회원가입창이 열려있다면 닫기.
                            }
                            await self.login(email: user.kakaoAccount?.email ?? "",
                                             password: String(describing: user.id))
                            return true
                        case .invalidEmail: // 이메일 형식이 잘못됨.
                            print("✔️\(user.kakaoAccount?.email ?? "") 이메일 형식이 잘못되었습니다.")
                            return false
                        default:
                            return false
                        }
                    }
                } else {
                    // 토큰정보가 있을 경우 로그인 진행
                    print("✔️\(user.kakaoAccount?.email ?? "카카오메일없음")")
                    await self.login(email: user.kakaoAccount?.email ?? "",
                                     password: String(describing: user.id))
                    return true
                }
            }
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            // TODO: - alert 하나 추가해서 상태띄워주는거 추가하면 좋을듯. 아직 보류 (23.10.15)
            print("✔️ERROR: 카카오톡 유저정보 못가져옴")
            return false
        }
        
        return false
    }
}
