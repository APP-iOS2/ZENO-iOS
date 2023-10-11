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
    private let commRepo = CommRepository.shared
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
	/// [커뮤니티최근검색] 최근 검색된 검색어들
	@Published var recentSearches: [String] = []
    /// 선택된 커뮤니티의 가입한지 3일이 지나지 않은 유저
    var recentlyJoinedMembers: [User] {
        guard let currentComm else { return [] }
        let users = currentCommMembers.filter {
            currentComm.joinMembers
                .filter {
                    let distanceSeconds = Date(timeIntervalSince1970: $0.joinedAt).toSeconds() - Date().toSeconds()
                    return distanceSeconds >= -86400 * 3
                }
                .map { $0.id }
                .contains($0.id)
        }
        return exceptCurrentUser(users: users)
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
    /// 선택된 커뮤니티의 가입된 멤버가 비었는지에 대한 Bool
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
	
    /// [커뮤니티 검색] 선택된 커뮤니티에서 userSearchTerm로 검색된 유저
    var searchedUsers: [User] {
        if userSearchTerm.isEmpty {
            return currentCommMembers
        } else {
            return currentCommMembers.filter { $0.name.contains(userSearchTerm) }
        }
    }
	
    /// [커뮤니티 검색] 모든 커뮤니티에서 communitySearchTerm로 검색된 커뮤니티
    var searchedComm: [Community] {
        var searchCom = allComm
            .filter { $0.name.lowercased().contains(commSearchTerm.lowercased()) }
        if !joinedComm.isEmpty {
			guard let currentUser else { return [] }
			
            searchCom = searchCom.filter { searched in
				!currentUser.commInfoList.contains { userComm in
					userComm.id == searched.id
				}
            }
        }
        return searchCom
    }
	/// 딥링크로 초대받은 커뮤니티 ID
    @Published var commIDInDeepLink: String = ""
    /// 딥링크 수신 정상 처리에 따라 가입하는 View를 보여주는 Bool
    @Published var isJoinWithDeeplinkView: Bool = false
    /// 딥링크로 초대받은 Community
    var filterDeeplinkComm: Community {
        guard let index = allComm.firstIndex(where: { $0.id == commIDInDeepLink }) else { return .emptyComm }
        return allComm[index]
    }
    
    init() {
        Task {
            await fetchAllComm()
            await fetchCurrentCommMembers()
        }
		loadRecentSearches() // 최근검색어 불러오기
    }
    /// 인자로 들어온 user와 currentComm에서 친구인지를 Bool로 리턴함
    func isFriend(user: User) -> Bool {
        guard let currentComm,
              let currentUser,
              let buddyList = currentUser.commInfoList
            .first(where: { $0.id == currentComm.id })?.buddyList
        else { return false }
        return buddyList.contains(user.id)
    }
    /// currentUser를 변경하는 함수
    func updateCurrentUser(user: User?) {
        self.currentUser = user
        filterJoinedComm()
    }
    /// 선택된 커뮤니티 Index를 변경하는 함수
    func changeSelectedComm(index: Int) {
        selectedComm = index
    }
    /// db에서 fetch한 모든 커뮤니티 중 currentUser가 속한 커뮤니티를 찾아 joinedComm을 업데이트함
    func filterJoinedComm() {
        guard let currentUser else { return }
        let commIDs = currentUser.commInfoList.map { $0.id }
        let communities = allComm.filter { commIDs.contains($0.id) }
        self.joinedComm = communities
    }
    
    func getCommunityByID(_ id: String) -> Community? {
        return allComm.first { community in
            community.id == id
        }
    }
    
    /// [가입신청] 그룹에 가입신청을 보냈었는지 확인하는 함수
    func checkApplied(comm: Community) -> Bool {
        guard let currentUser else { return false }
        return comm.waitApprovalMemberIDs.contains(currentUser.id) ? true : false
    }
    /// 뷰에 노출되는 user배열에서 currentUser를 제외하기 위한 함수
    private func exceptCurrentUser(users: [User]) -> [User] {
        guard let currentUser else { return users }
        return users.filter { $0.id != currentUser.id }
    }
	
	/// [커뮤니티최근검색] 최근검색어 저장하기
	func addSearchTerm(_ term: String) {
		guard !term.isEmpty else { return }
		guard !term.allSatisfy({ $0 == " " }) else { return }
		recentSearches = recentSearches.filter { $0 != term }
		recentSearches.insert(term, at: 0)
		saveRecentSearches()
	}
	
	/// [커뮤니티최근검색] 유저디폴트에 최신화
	func saveRecentSearches() {
		UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
		loadRecentSearches()
	}
	
	/// [커뮤니티최근검색] 최신화된 유저디폴트 불러오기
	private func loadRecentSearches() {
		if let savedSearches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
			recentSearches = savedSearches
		}
	}
    
    /// 딥링크 url의 정보를 구분해 초대받은 커뮤니티에 가입되어 있다면 해당 커뮤니티를 보여주고 가입되어 있지 않다면 가입할 수 있는 Modal View를 띄워주는 함수
    @MainActor
    func handleInviteURL(_ url: URL) async {
        await fetchAllComm()
        guard url.scheme == "zenoapp" else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("유효하지 않은 URL")
            return
        }
        guard let action = components.host, action == "invite" else {
            print("유효하지 않은 URL action")
            return
        }
        
        guard let commID = components.queryItems?.first(where: { $0.name == "commID" })?.value else {
            print("유효하지 않은 URL value")
            return
        }
        guard let currentUser else { return }
        if currentUser.commInfoList.contains(where: { $0.id == commID }) {
            guard let index = joinedComm.firstIndex(where: { $0.id == commID }) else { return }
            selectedComm = index
        } else {
            commIDInDeepLink = commID
            isJoinWithDeeplinkView = true
        }
    }
    /// 딥링크로 초대된 커뮤니티에 가입하는 함수
    @MainActor
    func joinCommWithDeeplink(commID: String) async {
        guard let currentUser,
              let willJoinComm = allComm.first(where: { $0.id == commID })
        else { return }
        let newMember = Community.Member(id: currentUser.id, joinedAt: Date().timeIntervalSince1970)
        let newCommMembers = willJoinComm.joinMembers + [newMember]
        do {
            try await firebaseManager.update(data: willJoinComm, value: \.joinMembers, to: newCommMembers)
            guard let index = allComm.firstIndex(where: { $0.id == willJoinComm.id }) else { return }
            allComm[index].joinMembers = newCommMembers
        } catch {
            print(#function + "커뮤니티 딥링크로 가입 시 커뮤니티의 joinMembers 업데이트 실패")
        }
    }
    /// 매니저가 커뮤니티를 제거하고 가입, 가입신청된 User의 commInfoList에서 커뮤니티 정보를 제거하는  함수
    @MainActor
    func deleteComm() async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            do {
                try await firebaseManager.delete(data: currentComm)
                let joinedIDs = currentComm.joinMembers.map { $0.id }
                let joinedResults = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: joinedIDs)
                await joinedResults.asyncForEach { [weak self] result in
                    switch result {
                    case .success(let user):
                        let removedCommInfo = user.commInfoList.filter { $0.id != currentComm.id }
                        do {
                            try await self?.firebaseManager.update(data: user, value: \.commInfoList, to: removedCommInfo)
                        } catch {
                            print(#function + "커뮤니티 삭제 후 \(user.id)에서 commInfoList의 삭제 된 커뮤니티 정보 제거 실패")
                        }
                    case .failure:
                        print(#function + "삭제 된 커뮤니티의 joinMembers의 id가 User Collection에서 Document 찾기 실패함")
                    }
                }
                let waitResults = await firebaseManager.readDocumentsWithIDs(type: User.self,
                                                                             ids: currentComm.waitApprovalMemberIDs)
                await waitResults.asyncForEach { [weak self] result in
                    switch result {
                    case .success(let user):
                        let removedCommInfo = user.commInfoList.filter { $0.id != currentComm.id }
                        do {
                            try await self?.firebaseManager.update(data: user, value: \.commInfoList, to: removedCommInfo)
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
    /// 매니저 권한 위임 함수
    @MainActor
    func delegateManager(user: User) async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            do {
                try await firebaseManager.update(data: currentComm, value: \.managerID, to: user.id)
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                allComm[commIndex] = currentComm
            } catch {
                print(#function + "매니저 권한 위임 업데이트 실패")
            }
        }
    }
    /// 매니저가 그룹 가입신청 수락하는 함수
    @MainActor
    func acceptMember(user: User) async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            let acceptedMember = Community.Member.init(id: user.id, joinedAt: Date().timeIntervalSince1970)
            let updatedWaitList = currentComm.waitApprovalMemberIDs.filter { $0 != acceptedMember.id }
            let updatedCurrentMembers = currentComm.joinMembers + [acceptedMember]
            do {
                try await firebaseManager.update(data: currentComm, value: \.waitApprovalMemberIDs, to: updatedWaitList)
                do {
                    try await firebaseManager.update(data: currentComm, value: \.joinMembers, to: updatedCurrentMembers)
                    guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                    allComm[commIndex].waitApprovalMemberIDs = updatedWaitList
                    allComm[commIndex].joinMembers = updatedCurrentMembers
                } catch {
                    print(#function + "커뮤니티 Document에 waitApprovalMemberIDs 업데이트 실패")
                }
            } catch {
                print(#function + "커뮤니티 Document에 joinMembers 업데이트 실패")
            }
        }
    }
    /// 매니저가 유저를 추방하는 함수
    @MainActor
    func deportMember(user: User) async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            let updatedJoinMembers = currentComm.joinMembers.filter { $0.id != user.id }
            let deportedMembersComm = user.commInfoList.filter({ $0.id != currentComm.id })
            do {
                try await firebaseManager.update(data: currentComm, value: \.joinMembers, to: updatedJoinMembers)
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                allComm[commIndex].joinMembers = updatedJoinMembers
                do {
                    try await firebaseManager.update(data: user, value: \.commInfoList, to: deportedMembersComm)
                } catch {
                    print(#function + "내보낸 유저 Document에 commInfoList 업데이트 실패")
                }
            } catch {
                print(#function + "커뮤니티 Document에 joinMembers 업데이트 실패")
            }
        }
    }
    /// db의 모든 커뮤니티를 받아오는 함수
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
        filterJoinedComm()
    }
    /// 커뮤니티의 설정(이미지, 이름, 설명, 검색여부)를 업데이트하는 함수
    @MainActor
    func updateCommInfo(comm: Community, image: UIImage?) async {
        do {
            if let image {
                let changedComm = try await firebaseManager.createWithImage(data: comm, image: image)
                guard let index = joinedComm.firstIndex(where: { $0.id == changedComm.id }) else { return }
                allComm[index] = changedComm
            } else {
                try await firebaseManager.create(data: comm)
                guard let index = joinedComm.firstIndex(where: { $0.id == comm.id }) else { return }
                allComm[index] = comm
            }
        } catch {
            print(#function + "Community Collection에 업데이트 실패")
        }
    }
    /// 새로운 커뮤니티를 생성하는 함수
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
                newComm = try await firebaseManager.createWithImage(data: newComm, image: image)
            } else {
                try await firebaseManager.create(data: newComm)
            }
            allComm.append(newComm)
        } catch {
            print(#function + "새 Community Collection에 추가 실패")
        }
    }
    /// 선택된 커뮤니티에 가입된 유저, 가입신청된 유저를 받아오는 함수
    @MainActor
    func fetchCurrentCommMembers() async {
        guard let currentCommMemberIDs = currentComm?.joinMembers.map({ $0.id }),
              let currentWaitMemberIDs = currentComm?.waitApprovalMemberIDs
        else { return }
        let results = await firebaseManager.readDocumentsWithIDs(type: User.self,
                                                                 ids: currentCommMemberIDs + currentWaitMemberIDs)
        let currentUsers = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.currentCommMembers = exceptCurrentUser(users: currentUsers)
            .filter { currentCommMemberIDs.contains($0.id) }
        if isCurrentCommManager {
            self.currentWaitApprovalMembers = exceptCurrentUser(users: currentUsers)
                .filter { currentWaitMemberIDs.contains($0.id) }
        }
    }
    /// 그룹 멤버가 그룹을 나갈 때 커뮤니티에서 나갈 멤버의 정보를 지우고 커뮤니티의 모든 유저정보를 받아와 해당 커뮤니티의 버디리스트에서 탈퇴한 유저를 지워서 업데이트하는 함수
    @MainActor
    func leaveComm() async {
        guard let currentComm,
              let currentUser
        else { return }
        let memberIDs = currentComm.joinMembers.map { $0.id }
        let changedMembers = currentComm.joinMembers.filter({ $0.id != currentUser.id })
        do {
            try await firebaseManager.update(data: currentComm, value: \.joinMembers, to: changedMembers)
            let results = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: memberIDs)
            await results.asyncForEach { [weak self] result in
                switch result {
                case .success(let user):
                    guard var updatedCommInfo = user.commInfoList
                        .first(where: { $0.id == currentComm.id }) else { return }
                    if updatedCommInfo.buddyList.contains(currentUser.id) {
                        do {
                            updatedCommInfo.buddyList = updatedCommInfo.buddyList.filter({ $0 != currentUser.id })
                            guard let index = user.commInfoList.firstIndex(where: { $0.id == updatedCommInfo.id }) else { return }
                            var updatedCommInfolist = user.commInfoList
                            updatedCommInfolist[index] = updatedCommInfo
                            try await self?.firebaseManager.update(data: user, value: \.commInfoList, to: updatedCommInfolist)
                        } catch {
                            print(#function + "탈퇴한 유저를 buddyList에 가진 User의 commInfoList 업데이트 실패")
                        }
                    }
                case .failure:
                    break
                }
            }
            guard let index = joinedComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
            joinedComm.remove(at: index)
            selectedComm = 0
        } catch {
            print(#function + "Community의 Members 업데이트 실패")
        }
    }
    /// [가입신청] 그룹에 가입신청 보내는 함수
    @MainActor
    func requestJoinComm(comm: Community) async {
        guard let currentUser else { return }
        guard !comm.waitApprovalMemberIDs.contains(currentUser.id) else { return }
		let newComm = comm.waitApprovalMemberIDs + [currentUser.id]
        do {
            try await firebaseManager.update(data: comm.self,
                                             value: \.waitApprovalMemberIDs,
                                             to: newComm)
			guard let index = allComm.firstIndex(where: { $0.id == comm.id }) else { return }
			allComm[index].waitApprovalMemberIDs = newComm
        } catch {
            print(#function + "그룹에 가입신청 실패")
        }
    }
}
