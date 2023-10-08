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
    /// App단에서 UserViewModel.currentUser가 변경될 때 CommViewModel.currentUser를 받아오는 함수로 유저 정보를 공유함
    private var currentUser: User?
    /// 마지막으로 선택한 커뮤니티의 Index값을 UserDefaults에 저장
    @AppStorage("selectedComm") private var selectedComm: Int = 0
    /// Firebase의 커뮤니티 Collection에 있는 모든 커뮤니티
    @Published var allComm: [Community] = []
    /// currentUser가 가입한 모든 커뮤니티
    @Published var joinedComm: [Community] = []
    /// currentUser가 마지막으로 선택한 커뮤니티, 가입된 커뮤니티가 없으면 nil을 반환
    var currentComm: Community? {
        guard joinedComm.count - 1 >= selectedComm else { return nil }
        return joinedComm[selectedComm]
    }
    /// 선택된 커뮤니티의 모든 유저(본인 포함)
    @Published var currentCommMembers: [User] = []
    /// 선택된 커뮤니티의 가입 대기중인 유저
    @Published var currentWaitApprovalMembers: [User] = []
    /// 선택된 커뮤니티의 가입한지 3일이 지나지 않은 유저
    var recentlyJoinedMembers: [User] {
        filterMembers(condition: .recentlyJoined)
    }
    /// [미사용중, 추후 판별 후 삭제] 선택된 커뮤니티의 가입한지 3일이 지난 유저
    var generalMembers: [User] {
        filterMembers(condition: .general)
    }
    /// 선택된 커뮤니티의 매니저인지 확인해 햄버거바의 세팅을 보여주기 위한 Bool
    var isCurrentCommManager: Bool {
        guard let currentUser,
              let currentComm
        else { return false }
        return currentComm.manager == currentUser.id
    }
    /// 유저가 선택된 커뮤니티의 알람을 켰는지에 대한 Bool
    var isAlertOn: Bool {
        currentUser?.commInfoList
            .filter({ currentComm?.id == $0.id })
            .first?.alert ?? false
    }
    /// 선택된 커뮤니티의 친구를 검색하기 위한 String
    @Published var userSearchTerm: String = ""
    /// 모든 커뮤니티를 검색하기 위한 String
    @Published var commSearchTerm: String = ""
    /// 선택된 커뮤니티에서 userSearchTerm로 검색된 유저
    var searchedUsers: [User] {
        if userSearchTerm.isEmpty {
            return currentCommMembers
        } else {
            return currentCommMembers.filter { $0.name.contains(userSearchTerm) }
        }
    }
    /// 모든 커뮤니티에서 communitySearchTerm로 검색된 커뮤니티
    var searchedComm: [Community] {
        if commSearchTerm.isEmpty {
            return joinedComm
        } else {
            return allComm
                .filter { $0.name.contains(commSearchTerm) }
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
    func updateComm(comm: Community, image: UIImage?) async {
        do {
            if let image {
                try await firebaseManager.createWithImage(data: comm, image: image)
            } else {
                try await firebaseManager.create(data: comm)
            }
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
    func createComm(comm: Community, image: UIImage?) async {
        guard let currentUser else { return }
        let createAt = Date().timeIntervalSince1970
        var newComm = comm
        newComm.manager = currentUser.id
        newComm.createdAt = createAt
        newComm.joinMembers = [.init(id: currentUser.id, joinedAt: createAt)]
        do {
            if let image {
                try await firebaseManager.createWithImage(data: newComm, image: image)
            } else {
                try await firebaseManager.create(data: newComm)
            }
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
