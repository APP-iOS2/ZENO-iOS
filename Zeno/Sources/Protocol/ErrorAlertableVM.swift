//
//  ErrorAlertableVM.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/24.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

protocol ErrorAlertableVM: ObservableObject {
    var error: Error? { get set }
    var isShowingErrorSheet: Bool { get set }
}

extension ErrorAlertableVM {
    func showingError(_ error: Error) {
        self.error = error
        isShowingErrorSheet = true
    }
}
