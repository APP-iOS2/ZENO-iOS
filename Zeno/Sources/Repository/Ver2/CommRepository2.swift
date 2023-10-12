////
////  CommRepository2.swift
////  Zeno
////
////  Created by gnksbm on 2023/10/11.
////  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
////
//
//import Foundation
//
//final class CommRepository2: Reducer {
//    struct State {
//        var currentUser: User?
//        var allComm: [Community]
//        var joinedComm: [Community]
//    }
//    
//    enum Action {
//        case setUser(user: User)
//        case setComms(allComms: [Community])
//        case getAllComm
//        case getJoinedComm
//    }
//    
//    let initialState = State(allComm: [], joinedComm: [])
//    
//    func reduce(state: inout State, action: Action) -> Effect {
//        switch action {
//        case let .setUser(user: user):
//            setUser(state: &state, user: user)
//        case let .setComms(allComms: allComms):
//            setComms(state: &state, allComms: allComms)
//        case .getAllComm:
//            break
//        case .getJoinedComm:
//            break
//        }
//        return .none
//    }
//    
//    func setUser(state: inout State, user: User?) {
//        state.currentUser = user
//    }
//    
//    func setComms(state: inout State, allComms: [Community]) {
//        guard let user = state.currentUser else { return }
//        state.allComm = allComms
//        state.joinedComm = allComms.filter { comm in
//            return user.commInfoList.contains(where: { $0.id == comm.id })
//        }
//    }
//}
