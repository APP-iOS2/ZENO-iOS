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
        return currentComm.managerID == currentUser.id
    }
    /// 유저가 선택된 커뮤니티의 알람을 켰는지에 대한 Bool
    var isAlertOn: Bool {
        currentUser?.commInfoList
            .filter({ currentComm?.id == $0.id })
            .first?.alert ?? false
    }
    var isCurrentCommMembersEmpty: Bool {
        guard let currentComm,
              let currentUser
        else { return true }
        let exceptManagerList = currentComm.joinMembers.filter({ $0.id != currentUser.id })
        return exceptManagerList.isEmpty
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
    @Published var commIDInDeepLink: String = ""
    @Published var isJoinWithDeeplinkView: Bool = false
    
    var filterDeeplinkComm: Community {
        guard let index = allComm.firstIndex(where: { $0.id == commIDInDeepLink }) else { return .emptyComm }
        return allComm[index]
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
        filterJoinedComm()
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
    
    func handleInviteURL(_ url: URL) {
        guard url.scheme == "ZenoApp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }

        guard let action = components.host, action == "invite" else {
            print("Unknown URL, we can't handle this one!")
            return
        }
        
        guard let queryItem = components.queryItems else {
            return
        }
        
        if let commID = queryItem.first(where: { $0.name == "commID" })?.value {
            commIDInDeepLink = commID
            isJoinWithDeeplinkView = true
        }
    }
    
    @MainActor
    func joinCommWithDeeplink(commID: String) async {
        guard var currentUser,
              let index = allComm.firstIndex(where: { $0.id == commID })
        else { return }
        let joinedAt = Date().timeIntervalSince1970
        var invitedComm = allComm[index]
        invitedComm.joinMembers.append(.init(id: currentUser.id, joinedAt: joinedAt))
        currentUser.commInfoList.append(.init(id: commID, buddyList: [], alert: true))
        do {
            _ = try await firebaseManager.create(data: invitedComm)
            do {
                _ = try await firebaseManager.create(data: currentUser)
                allComm.append(invitedComm)
            } catch {
                print(#function + "커뮤니티 딥링크로 가입 시 유저의 commInfoList 업데이트 실패")
            }
        } catch {
            print(#function + "커뮤니티 딥링크로 가입 시 커뮤니티의 joinMembers 업데이트 실패")
        }
    }
    
    @MainActor
    func deleteComm() async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            let joinedIDs = currentComm.joinMembers.map { $0.id }
            do {
                _ = try await firebaseManager.delete(data: currentComm)
                let joinedResults = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: joinedIDs)
                await joinedResults.asyncForEach { [weak self] result in
                    switch result {
                    case .success(var user):
                        guard let index = user.commInfoList.firstIndex(where: { $0.id == currentComm.id }) else { return }
                        user.commInfoList.remove(at: index)
                        do {
                            try await self?.firebaseManager.create(data: user)
                        } catch {
                            print(#function + "커뮤니티 삭제 후 \(user.id)에서 commInfoList의 삭제 된 커뮤니티 정보 제거 실패")
                        }
                    case .failure:
                        print(#function + "삭제 된 커뮤니티의 joinMembers의 id가 User Collection에서 Document 찾기 실패함")
                    }
                }
                let waitResults = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: currentComm.waitApprovalMemberIDs)
                await waitResults.asyncForEach { [weak self] result in
                    switch result {
                    case .success(var user):
                        guard let index = user.commInfoList.firstIndex(where: { $0.id == currentComm.id }) else { return }
                        user.commInfoList.remove(at: index)
                        do {
                            try await self?.firebaseManager.create(data: user)
                        } catch {
                            print(#function + "커뮤니티 삭제 후 \(user.id)에서 commInfoList의 삭제 된 커뮤니티 정보 제거 실패")
                        }
                    case .failure:
                        print(#function + "삭제 된 커뮤니티의 waitApprovalMembers의 id가 User Collection에서 Document 찾기 실패함")
                    }
                }
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                allComm.remove(at: commIndex)
            } catch {
                print(#function + "그룹 삭제 실패")
            }
        }
    }
    
    @MainActor
    func delegateManager(user: User) async {
        if isCurrentCommManager {
            guard var currentComm else { return }
            currentComm.managerID = user.id
            do {
                _ = try await firebaseManager.create(data: currentComm)
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                allComm[commIndex] = currentComm
            } catch {
                print(#function + "매니저 권한 위임 실패")
            }
        }
    }
    
    @MainActor
    func acceptMember(user: User) async {
        if isCurrentCommManager {
            guard var currentComm,
                  let index = currentComm.waitApprovalMemberIDs.firstIndex(where: { $0 == user.id })
            else { return }
            let tempMemberID = currentComm.waitApprovalMemberIDs.remove(at: index)
            let acceptMember = Community.Member.init(id: tempMemberID, joinedAt: Date().timeIntervalSince1970)
            currentComm.joinMembers.append(acceptMember)
            do {
                _ = try await firebaseManager.create(data: currentComm)
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                allComm[commIndex] = currentComm
            } catch {
                print(#function + "그룹가입 수락 실패")
            }
        }
    }
    
    @MainActor
    func deportMember(user: User) async {
        if isCurrentCommManager {
            guard var currentComm,
                  let memberIndex = currentComm.joinMembers.firstIndex(where: { $0.id == user.id }),
                  let commIndex = user.commInfoList.firstIndex(where: { $0.id == currentComm.id })
            else { return }
            currentComm.joinMembers.remove(at: memberIndex)
            var deportedUser = user
            deportedUser.commInfoList = deportedUser.commInfoList.filter({ $0.id == currentComm.id })
            do {
                _ = try await firebaseManager.create(data: currentComm)
                _ = try await firebaseManager.create(data: deportedUser)
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                allComm[commIndex] = currentComm
            } catch {
                print(#function + "그룹에서 내보내기 실패")
            }
        }
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
            guard let image else {
                try await firebaseManager.create(data: comm)
                return
            }
            let changedComm = try await firebaseManager.createWithImage(data: comm, image: image)
            guard let index = joinedComm.firstIndex(where: { $0.id == changedComm.id }) else {
                print(#function + "업데이트된 Community의 ID joinedCommunities에서 찾을 수 없음")
                return
            }
            allComm[index] = changedComm
        } catch {
            print(#function + "Community Collection에 업데이트 실패")
        }
    }
    
    @MainActor
    func createComm(comm: Community, image: UIImage?) async {
        guard let currentUser else { return }
        let createAt = Date().timeIntervalSince1970
        var newComm = comm
        newComm.managerID = currentUser.id
        newComm.createdAt = createAt
        newComm.joinMembers = [.init(id: currentUser.id, joinedAt: createAt)]
        do {
            if let image {
                _ = try await firebaseManager.createWithImage(data: newComm, image: image)
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
        if isCurrentCommManager {
            await fetchCurrentWaitMembers()
        }
    }
    
    @MainActor
    private func fetchCurrentWaitMembers() async {
        guard let currentWaitMemberIDs = currentComm?.waitApprovalMemberIDs else { return }
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
            guard let index = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
            allComm.remove(at: index)
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
