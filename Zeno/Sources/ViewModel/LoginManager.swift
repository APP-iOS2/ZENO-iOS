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
    func memberRemove() async -> Bool
}

/// 싱글톤 로그인상태모델 -> signStatus값을 동일한 걸 바라봐야하기 때문(공유x). 실제 분기처리됨.
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

/// 로그인기능 뷰모델
final class LoginManager {
    /// 로그인 상태 기능 위임자
    weak var loginDeleGate: LoginStatusDelegate?
    
    init(delegate: LoginStatusDelegate) {
        self.loginDeleGate = delegate
        print(#function, "✔️")
    }
    
    @MainActor
    func login() async {
        print(#function, "✔️")
        let islogined = await loginDeleGate?.login()
        if let islogined, islogined {
            SignStatusObserved.shared.signStatus = .signIn
            SignStatus.signIn.saveStatus()
            print(#function, "✔️signIn으로 값 변경됨.")
        }
    }
    
    @MainActor
    func logout() async {
        print(#function, "✔️")
        await loginDeleGate?.logout()
        SignStatusObserved.shared.signStatus = .unSign
        SignStatus.unSign.saveStatus()
        SignStatusObserved.shared.isNeedLogin = true
        UserDefaults.standard.set(true, forKey: "nickNameChanged") // 회원가입 여부 -> 로그아웃시에는 무조건 true로 바꿔주자.
                                                                   // 왜냐면, 로그아웃버튼을 누른다는건 회원가입이 된 유저가 로그아웃을 누른다는것이기때문 (또 view가 열릴필요가 없다)
                                                                  // creatUser를 하는 경우에 다시 false로 set을 해주고 있기때문에 상관없음.!
        print(#function, "✔️unSign으로 값 변경됨.")
    }
    
    @MainActor
    func memberRemove() async {
        print(#function, "✔️")
        let isCompleted = await loginDeleGate?.memberRemove()
        
        if let isCompleted, isCompleted {
            SignStatusObserved.shared.signStatus = .unSign
            SignStatus.unSign.saveStatus() // 바꿔줘서 로그인창으로 변경되게 한 후
            SignStatus.removeStatus()   // 해당 UserDefault 삭제
            UserDefaults.standard.removeObject(forKey: "nickNameChanged") // 회원가입 여부 유저디폴트 삭제
            print(#function, "✔️sign상태, 회원가입상태 remove")
            SignStatusObserved.shared.isNeedLogin = true
        } else {
            // TODO: 삭제 못했을경우 어떻게 할까
        }
    }
}
