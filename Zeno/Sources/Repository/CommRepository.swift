//
//  CommRepository.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

class CommRepository {
    static let shared = CommRepository()
    private let semaphore = DispatchSemaphore(value: 1)
    
    private let fbManager = FirebaseManager.shared
    
    private var currentUser: User?
    private var allComm: [Community] = []
    private var joinedComm: [Community] = []
    
    enum Action {
        case set(communities: [Community])
        case getAll
        case getjoined
    }
    
    private init() {
        Task {
            await fetchAllComm()
        }
    }
    
    @discardableResult
    func reduce(action: Action) -> [Community]? {
        var result: [Community]?
        semaphore.wait()
        switch action {
        case let .set(communities):
            setAllComm(communities)
        case .getAll:
            result = getAllComm()
        case .getjoined:
            result = getJoinedComm()
        }
        semaphore.signal()
        return result
    }
    
    @MainActor
    func fetchAllComm() async {
        let results = await fbManager.readAllCollection(type: Community.self)
        let communities = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        reduce(action: .set(communities: communities))
        filterJoinedComm()
    }
    
    private func filterJoinedComm() {
        guard let currentUser else { return }
        let commIDs = currentUser.commInfoList.map { $0.id }
        let communities = allComm.filter { commIDs.contains($0.id) }
        self.joinedComm = communities
    }
    
    private func setUser(_ object: User?) {
        semaphore.wait()
        currentUser = object
        semaphore.signal()
        filterJoinedComm()
    }
    
    private func setAllComm(_ objects: [Community]) {
        allComm = objects
        joinedComm = allComm.filter { comm in
            guard let currentUser else { return false }
            return currentUser.commInfoList.contains(where: { $0.id == comm.id })
        }
    }
    
    private func getAllComm() -> [Community] {
        return allComm
    }
    
    private func getJoinedComm() -> [Community] {
        return joinedComm
    }
}
