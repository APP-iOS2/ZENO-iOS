//
//  CommViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

class CommViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private var currentUser: User?
    
    @AppStorage("selectedCommunity") private var selectedComm: Int = 0
    @Published var allComm: [Community] = []
    @Published var joinedComm: [Community] = []
    var currentComm: Community? {
        guard joinedComm.count - 1 >= selectedComm else { return nil }
        return joinedComm[selectedComm]
    }
    
    @Published var currentCommMembers: [User] = []
    @Published var currentWaitApprovalMembers: [User] = []
    var recentlyJoinedMembers: [User] {
        filterMembers(condition: .recentlyJoined)
    }
    var generalMembers: [User] {
        filterMembers(condition: .general)
    }
    
    @Published var userSearchTerm: String = ""
    @Published var communitySearchTerm: String = ""
    var searchedUsers: [User] {
        if userSearchTerm.isEmpty {
            return generalMembers
        } else {
            return generalMembers.filter { $0.name.contains(userSearchTerm) }
        }
    }
    var searchedCommunity: [Community] {
        if communitySearchTerm.isEmpty {
            return joinedComm
        } else {
            return allComm
                .filter { $0.name.contains(communitySearchTerm) }
                .filter { allComm in
                    joinedComm.contains { $0.id != allComm.id }
                }
        }
    }
    
    init() {
        Task {
            await fetchAllComm()
        }
    }
    
    private enum MemberCondition {
        case recentlyJoined, general
    }
    
    func updateCurrentUser(user: User?) {
        self.currentUser = user
        Task {
            await fetchAllComm()
        }
    }
    
    func changeSelectedComm(index: Int) {
        selectedComm = index
    }
    
    func filterJoinedComm() {
        guard let currentUser else { return }
        let commIDs = currentUser.commInfoList.map { $0.id }
        let communities = allComm.filter { commIDs.contains($0.id) }
        self.joinedComm = communities
    }
    
    @MainActor
    func fetchAllComm() async {
        let results = await firebaseManager.readAllCollection(type: Community.self)
        let communities = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.allComm = communities
    }
    
    @MainActor
    func updateComm(comm: Community) async {
        do {
            try await firebaseManager.create(data: comm)
            guard let index = joinedComm.firstIndex(where: { $0.id == comm.id }) else {
                print(#function + "업데이트된 Community의 ID joinedCommunities에서 찾을 수 없음")
                return
            }
            joinedComm[index] = comm
        } catch {
            print(#function + "Community Collection에 업데이트 실패")
        }
    }
    
    @MainActor
    func createComm(comm: Community) async {
        guard let currentUser else { return }
        let createAt = Date().timeIntervalSince1970
        var newComm = comm
        newComm.manager = currentUser.id
        newComm.createdAt = createAt
        newComm.joinMembers = [.init(id: currentUser.id, joinedAt: createAt)]
        do {
            try await firebaseManager.create(data: newComm)
            allComm.append(newComm)
        } catch {
            print(#function + "새 Community Collection에 추가 실패")
        }
    }
    
    @MainActor
    func fetchCurrentCommMembers() async {
        guard let currentCommMemberIDs = currentComm?.joinMembers.map({ $0.id }) else { return }
        let results = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: currentCommMemberIDs)
        let currentUsers = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.currentCommMembers = exceptCurrentUser(users: currentUsers)
        await fetchCurrentWaitMembers()
    }
    
    @MainActor
    private func fetchCurrentWaitMembers() async {
        guard let currentWaitMemberIDs = currentComm?.waitApprovalMembers.map({ $0.id }) else { return }
        let results = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: currentWaitMemberIDs)
        let currentWaitUsers = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.currentWaitApprovalMembers = exceptCurrentUser(users: currentWaitUsers) 
    }
    
    @MainActor
    func leaveComm() async {
        guard var currentComm,
              let currentUser
        else { return }
        currentComm.joinMembers = currentComm.joinMembers.filter({ $0.id != currentUser.id })
        do {
            try await firebaseManager.create(data: currentComm)
            guard let index = joinedComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
            joinedComm.remove(at: index)
            selectedComm = 0
        } catch {
            print(#function + "Community의 Members에서 탈퇴할 유저정보 삭제 실패")
        }
    }
    
    private func filterMembers(condition: MemberCondition) -> [User] {
        guard let currentComm else { return [] }
        let filterMember: [Community.Member]
        switch condition {
        case .recentlyJoined:
            filterMember = currentComm.joinMembers.filter {
                $0.joinedAt - Date().timeIntervalSince1970 < -86400 * 3
            }
        case .general:
            filterMember = currentComm.joinMembers.filter {
                $0.joinedAt - Date().timeIntervalSince1970 >= -86400 * 3
            }
        }
        let users = currentCommMembers.filter {
            filterMember
                .map { $0.id }
                .contains($0.id)
        }
        return exceptCurrentUser(users: users)
    }
    
    private func exceptCurrentUser(users: [User]) -> [User] {
        guard let currentUser else { return users }
        return users.filter { $0.id != currentUser.id }
    }
}
