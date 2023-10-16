//
//  LoginViewModel.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/17.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    /// 로그인여부 상태값
    @Published var signStatus: SignStatus
    private var user: User
    
    init(user: User) {
        self.signStatus = .unSign
        self.user = user
        getSignStatus()
    }
    
    private func getSignStatus() {
        self.signStatus = SignStatus.getStatus() // signStatus 값 가져오기. User정보를 받았을때
        print("🦕signStatus = \(self.signStatus.rawValue)")
    }
    
    private func setSignStatus(_ status: SignStatus) {
        self.signStatus = status
        self.signStatus.saveStatus()
    }
}
