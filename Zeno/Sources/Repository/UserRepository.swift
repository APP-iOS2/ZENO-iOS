//
//  UserRepository.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

class UserRepository {
    static let shared = UserRepository()
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var currentUser: User?
    
    enum Action {
        case set(user: User)
        case get
    }
    
    private init() { }
    
    @discardableResult
    func reduce(action: Action) -> User? {
        var result: User?
        semaphore.wait()
        switch action {
        case let .set(user):
            setUser(user)
        case .get:
            result = getUser()
        }
        semaphore.signal()
        return result
    }
    
    private func setUser(_ object: User?) {
        currentUser = object
    }
    
    private func getUser() -> User? {
        return currentUser
    }
}
