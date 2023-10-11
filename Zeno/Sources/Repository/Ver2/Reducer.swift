//
//  Reducer.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import Combine

public protocol Reducer {
    associatedtype State
    associatedtype Action
    
    typealias Effect = EffectType<Action>
    
    var initialState: State { get }
    
    func reduce(state: inout State, action: Action) -> Effect
}

public enum EffectType<Action> {
    case publisher(AnyPublisher<Action, Never>)
    case task(Task<Action, Never>)
    case none
}
