//
//  LoginViewModel.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/17.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

/// 로그인 여부 UserDefault에 저장
enum SignStatus: String {
    case signIn, unSign
    
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
            return .unSign
        }
    }
    
    static func removeStatus() {
        UserDefaults.standard.removeObject(forKey: "KakaoSignStatus")
    }
}

/// 로그인관련 기능 위임 프로토콜
protocol LoginStatusDelegate: AnyObject {
    /// 로그인
    func login() async -> Bool
    /// 로그아웃
    func logout() async
    /// 회원탈퇴
    func memberRemove() async
}

/// 싱글톤 로그인상태모델 -> signStatus값을 동일한 걸 바라봐야하기 때문. 실제 분기처리됨.
final class SignStatusObserved: ObservableObject {
    static let shared = SignStatusObserved()
    private init() {
        self.isNeedLogin = false
        self.signStatus = SignStatus.getStatus()
        print(#function, "✔️SignStatusObserved \(self.signStatus)")
    }
    
    @Published var signStatus: SignStatus
    @Published var isNeedLogin: Bool
}

final class LoginViewModel {
    /// 로그인 상태 기능 위임자
    weak var loginDeleGate: LoginStatusDelegate?
    
    /// 로그인여부 상태값
    private var signStatus: SignStatus
    
    init(delegate: LoginStatusDelegate) {
        self.loginDeleGate = delegate
        print(#function, "✔️")
        self.signStatus = .unSign
        self.getSignStatus() // 유저디폴트값 가져오기
        print(#function, "✔️ \(self.signStatus)")
    }
    
    /// signStatus 값 UserDefault에서 가져오기
    private func getSignStatus() {
        self.signStatus = SignStatus.getStatus() // signStatus 값 가져오기. User정보를 받았을때
        SignStatusObserved.shared.signStatus = self.signStatus
        print("✔️signStatus = \(self.signStatus.rawValue)")
    }
    
    /// signStatus값 UserDefault에 저장.
    private func setSignStatus(_ status: SignStatus) {
        self.signStatus = status
        SignStatusObserved.shared.signStatus = status
        self.signStatus.saveStatus()
    }
    
    @MainActor
    func login() async {
        print(#function, "✔️")
        let islogined = await loginDeleGate?.login()
        if let islogined, islogined {
            self.setSignStatus(.signIn)
            print(#function, "✔️ signIn으로 값 변경됨.")
        }
    }
    
    @MainActor
    func logout() async {
        print(#function, "✔️")
        await loginDeleGate?.logout()
        self.setSignStatus(.unSign)
        SignStatusObserved.shared.isNeedLogin = true
        print(#function, "✔️unSign으로 값 변경됨.")
    }
    
    @MainActor
    func memberRemove() async {
        print(#function, "✔️")
        await loginDeleGate?.memberRemove()
        self.setSignStatus(.unSign) // 바꿔줘서 로그인창으로 변경되게 한 후
        SignStatus.removeStatus()   // 해당 UserDefault 삭제
        print(#function, "✔️sign상태 remove")
        UserDefaults.standard.removeObject(forKey: "nickNameChanged") // 회원가입 여부 유저디폴트 삭제
        SignStatusObserved.shared.isNeedLogin = true
    }
}
