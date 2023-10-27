//
//  CommViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKTalk
import KakaoSDKTemplate
import KakaoSDKShare
import Firebase
import FirebaseFirestoreSwift
/*
 snapshot - [CurrentUser, CurrentCommunity]
    1. CurrentUser: 초기화 시점에 무조건 등록됨
    2. CurrentCommunity:
        - 유저디폴트에 커뮤니티 있을 때(CurrentCommID)
            - 저장되어있는 커뮤니티에 연결함 [v] addCommunitySnapshot
            - 유저디폴트에 있는 커뮤니티에서 앱이 종료되어있는동안 추방을 당했을 때 <- commID.removeAll()
        - 유저디폴트에 커뮤니티 없을 때(CurrentCommID)
            - 유저가 가입한 커뮤니티가 없을 때  <- commID.removeAll()
            - 유저가 가입한 커뮤니티가 있을 때  <- 유저의 첫번째 커뮤니티에 연결함 [v] addCommunitySnapshot
    2-1. snapshot 못걸게 막아야함
        - addCommunitySnapshot()에서 commID를 빈문자열일 때 리턴시켜서 안걸게 만듬
 */

// TODO: 추방당하면 그룹 안보이게해야함
final class CommViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private let commRepo = CommRepository.shared
    private var userListener: ListenerRegistration?
    private var commListener: ListenerRegistration?
    /// 앱 시작을 딥링크로 할 때 유저 정보를 받아온 뒤 딥링크를 처리하기 위한 클로저
    var deepLinkHandler: () -> Void = { }
    /// App단에서 UserViewModel.currentUser가 변경될 때 CommViewModel.currentUser를 받아오는 함수로 유저 정보를 공유함
    @Published private(set) var currentUser: User?
    /// 마지막으로 선택한 커뮤니티의 ID를 UserDefaults에 저장
    @AppStorage("selectedCommID") var currentCommID: Community.ID = ""
    /// currentUser가 가입한 모든 커뮤니티
    @Published var joinedComm: [Community] = []
    /// currentUser가 마지막으로 선택한 커뮤니티, 가입된 커뮤니티가 없으면 nil을 반환
    @Published var currentComm: Community?
    /// 선택된 커뮤니티의 모든 유저(본인 포함)
    @Published var currentCommMembers: [User] = []
    /// 선택된 커뮤니티의 가입 대기중인 유저
    @Published var currentWaitApprovalMembers: [User] = []
	/// [커뮤니티최근검색] 최근 검색된 검색어들
	@Published var recentSearches: [String] = []
	/// [가입 신청된 그룹]
	/// [매니저 위임] 매니저 바뀌었을 때 알람
	@Published var managerChangeWarning: Bool = false
	/// [그룹정원 초과] 구성원 관리에서 그룹정원이 초과되었을 때 알람
	@Published var overCapacity: Bool = false
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
        return exceptCurrentUser(users)
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
    /// [커뮤니티 검색] 선택된 커뮤니티에서 userSearchTerm로 검색된 유저
    var searchedUsers: [User] {
        if userSearchTerm.isEmpty {
            return currentCommMembers
        } else {
            return currentCommMembers.filter { $0.name.contains(userSearchTerm) }
        }
    }
    /// 모든 커뮤니티를 검색하기 위한 String
    @Published var commSearchTerm: String = ""
    /// [커뮤니티 검색] 모든 커뮤니티에서 communitySearchTerm로 검색된 커뮤니티
    @Published var searchedComm: [Community] = []
	/// 딥링크로 초대받은 커뮤니티 ID
    @Published var deepLinkTargetComm: Community = .emptyComm
    /// 딥링크 수신: 가입하는 View를 보여주는 Bool
    @Published var isJoinWithDeeplinkView: Bool = false
    /// 딥링크 수신: 해당하는 커뮤니티가 존재하지 않을 때 알림을 보여주는 Bool
    @Published var isDeepLinkExpired: Bool = false
    /// 커뮤니티 검색화면을 띄워주기 위한 Bool
    @Published var isShowingSearchCommSheet: Bool = false
    /// 가입된 커뮤니티를 띄워주기 위한 Bool
    @Published var isShowingCommListSheet: Bool = false
    /// 데이터 로딩상태에 따라 CommMainView의 ProgressView를 보여주는 여부
    @Published var isFetchComplete: Bool = false
    
    init() {
        loadRecentSearches() // 최근검색어 불러오기
    }
    /// [그룹 메인 뷰] 현재 커뮤니티의 매니저인지 확인
    func checkManagerUser(user: User) -> Bool {
        guard let managerID = currentComm?.managerID.description else { return false }
        return managerID == user.id
    }
    /// 인자로 들어온 user와 currentComm에서 친구인지를 Bool로 리턴함
	@MainActor
    func isFriend(user: User) -> Bool {
        guard let currentComm,
              let currentUser,
              let buddyList = currentUser.commInfoList
            .first(where: { $0.id == currentComm.id })?.buddyList
        else { return false }
        return buddyList.contains(user.id)
    }
    /// 홈탭에서 사용하는 가입된 커뮤니티 관련 메서드
    func getCommunityByID(_ id: String) -> Community? {
        return joinedComm.first { community in
            community.id == id
        }
    }
    /// [가입신청] 그룹에 가입신청을 보냈었는지 확인하는 함수
    func checkApplied(comm: Community) -> Bool {
        guard let currentUser else { return false }
        return comm.waitApprovalMemberIDs.contains(currentUser.id) ? true : false
    }
	/// [커뮤니티최근검색] 최근검색어 저장하기
	func addSearchTerm(_ term: String) {
		guard !term.isEmpty else { return }
		guard !term.allSatisfy({ $0 == " " }) else { return }
		recentSearches = recentSearches.filter { $0 != term }
		if recentSearches.count > 10 {
			recentSearches.removeLast()
		}
		recentSearches.insert(term, at: 0)
		
		saveRecentSearches()
	}
	/// [커뮤니티최근검색] 유저디폴트에 최신화
	func saveRecentSearches() {
		UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
		loadRecentSearches()
	}
    /// [커뮤니티최근검색] 유저디폴트에서 인자로 들어온 검색기록 삭제
    func removeSearchTerm(_ term: String) {
        recentSearches.removeFirstElement(term)
        saveRecentSearches()
    }
    /// User배열에서 현재 로그인된 유저를 제외하기 위한 함수
    private func exceptCurrentUser(_ users: [User]) -> [User] {
        guard let currentUser else { return users }
        return users.filter { $0.id != currentUser.id }
    }
    /// User배열에서 현재 로그인된 유저를 첫번째 순서로 바꾸기 위한 함수
    private func sortCurrentUserToFirst(_ users: [User]) -> [User] {
        guard let currentUser,
              let index = users.firstIndex(of: currentUser)
        else { return users }
        var results = users
        results.swapAt(0, index)
        return results
    }
	/// [커뮤니티최근검색] 최신화된 유저디폴트 불러오기
	private func loadRecentSearches() {
		if let savedSearches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
			recentSearches = savedSearches
		}
	}
    
    // MARK: Interaction
    /// 커뮤니티 추천(미구현)
    func recomendComm() async {
        guard let allBuddies = currentUser?.commInfoList.flatMap({ $0.buddyList }) else { return }
        
        _ = Dictionary(grouping: allBuddies) { $0 }
//        let closeFriend = Dictionary(grouping: allBuddies) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
    /// searchedComm을 업데이트하는 함수
    @MainActor
    func searchComm() async {
        let result = await firebaseManager.searchContains(type: Community.self, value: \.name, searchTerm: commSearchTerm)
        switch result {
        case .success(let success):
            searchedComm = success
                .filter({ comm in !joinedComm.contains { $0.id == comm.id } })
                .filter({ $0.name.contains(commSearchTerm) })
        case .failure:
            searchedComm = []
        }
    }
    /// 커뮤니티별 알람정보를 변경해주는 함수
    func commAlertToggle() async {
        guard let currentUser,
              let currentComm
        else { return }
        var updatedCommList = currentUser.commInfoList
        guard let updatedComm = currentUser.commInfoList.first(where: { $0.id == currentComm.id }),
              let index = updatedCommList.firstIndex(where: { $0.id == updatedComm.id })
        else { return }
        updatedCommList[index].alert.toggle()
        do {
            try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: updatedCommList)
        } catch {
            print(#function + "User Collection에 알람정보 업데이트 실패")
        }
    }
    /// [가입신청] 가입 신청된 커뮤니티 불러오기
    func getRequestComm() async -> [Community] {
        guard let currentUser else { return [] }
        
        let results =  await firebaseManager.readDocumentsWithIDs(type: Community.self, ids: currentUser.requestComm)
        
        var requestComm: [Community] = []
        
        await results.asyncForEach { result in
            switch result {
            case .success(let comm):
                requestComm.append(comm)
            case .failure:
                print("가입신청 보낸 그룹 정보 불러오기 실패")
            }
        }
        return requestComm
    }
    /// 인자로 들어온 커뮤니티에 친구추가하는 함수
    func addFriend(user: User, comm: Community) async {
        guard let currentUser,
              let index = currentUser.commInfoList.firstIndex(where: { $0.id == comm.id }) else { return }
        var newInfo = currentUser.commInfoList
        newInfo[index].buddyList.append(user.id)
        do {
            try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: newInfo)
        } catch {
            print(#function + "User Document에 commInfoList 업데이트 실패")
        }
    }
    // db의 User 컬렉션중 currentComm에 가입된 유저 탐색 후 commInfo 삭제
    private func deleteJoinedMembersInfo(comm: Community) async {
        let joinedMemberIDs = comm.joinMembers.map { $0.id }
        let joinedResults = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: joinedMemberIDs)
        await joinedResults.asyncForEach { [weak self] result in
            switch result {
            case .success(let user):
                let removedCommInfo = user.commInfoList.filter { $0.id != comm.id }
                do {
                    try await self?.firebaseManager.update(data: user,
                                                           value: \.commInfoList,
                                                           to: removedCommInfo)
                } catch {
                    print(#function + "커뮤니티 삭제 후 \(user.id)에서 commInfoList의 삭제 된 커뮤니티 정보 제거 실패")
                }
            case .failure:
                print(#function + "삭제 된 커뮤니티의 joinMembers의 id가 User Collection에서 Document 찾기 실패함")
            }
        }
    }
    // db의 User 컬렉션중 currentComm에 가입신청된 유저 탐색 후 삭제
    private func deleteWaitMembersInfo(comm: Community) async {
        let waitResults = await firebaseManager.readDocumentsWithIDs(
            type: User.self,
            ids: comm.waitApprovalMemberIDs
        )
        await waitResults.asyncForEach { [weak self] result in
            switch result {
            case .success(let user):
                let removedRequests = user.requestComm.filter { $0 != comm.id }
                do {
                    try await self?.firebaseManager.update(data: user,
                                                           value: \.requestComm,
                                                           to: removedRequests)
                    await self?.deleteAlarm(user: user, comm: comm)
                } catch {
                    print(#function + "커뮤니티 삭제 후 \(user.id)에서 commInfoList의 삭제 된 커뮤니티 정보 제거 실패")
                }
            case .failure:
                print(#function + "삭제 된 커뮤니티의 waitApprovalMembers의 id가 User Collection에서 Document 찾기 실패함")
            }
        }
    }
    /// 매니저가 커뮤니티를 제거하고 가입, 가입신청된 User의 commInfoList에서 커뮤니티 정보를 제거하는  함수
    @MainActor
    func deleteComm() async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            do {
                // currentComm 정보 삭제
                try await firebaseManager.delete(data: currentComm)
                await deleteJoinedMembersInfo(comm: currentComm)
                await deleteWaitMembersInfo(comm: currentComm)
                // 작업이 끝나고 currentCommID 변경
                if let currentCommID = currentUser?.commInfoList.first {
                    setCurrentID(id: currentCommID.id)
                } else {
                    setCurrentID()
                }
            } catch {
                print(#function + "그룹 삭제 실패")
            }
        }
    }
	/// [가입 신청 취소]
	func removeJoinRequestUser(comm: Community) async {
		guard let currentUser else { return }
		
		let updatedWaitList = comm.waitApprovalMemberIDs
			.filter { $0 != currentUser.id }
		
		do {
			try await firebaseManager.update(data: currentUser,
											 value: \.requestComm,
											 to: currentUser.requestComm.filter({ $0 != comm.id }))
			try await firebaseManager.update(data: comm,
											 value: \.waitApprovalMemberIDs,
											 to: updatedWaitList)
		} catch {
			print(#function + "그룹 가입 신청 취소 실패")
		}
	}
    /// 매니저가 그룹 가입신청 수락하는 함수
    func acceptMember(user: User) async {
        if isCurrentCommManager {
            guard let currentComm else { return }
			guard currentComm.joinMembers.count < currentComm.personnel else {
				overCapacity = true
				print("정원초과")
				return
			}
            let acceptedMember = Community.Member.init(id: user.id,
                                                       joinedAt: Date().timeIntervalSince1970)
            let updatedWaitList = currentComm.waitApprovalMemberIDs
                .filter { $0 != acceptedMember.id }
            let updatedCurrentMembers = currentComm.joinMembers + [acceptedMember]
            do {
                // 가입한 유저의 커뮤니티 목록 업데이트
                try await firebaseManager.update(data: user,
                                                 value: \.commInfoList,
                                                 to: user.commInfoList + [.init(id: currentComm.id)])
                try await firebaseManager.update(data: user,
                                                 value: \.requestComm,
                                                 to: user.requestComm.filter({ $0 != currentComm.id }))
                do {
                    // currentComm에 가입한 유저 목록 업데이트
                    try await firebaseManager.update(data: currentComm,
                                                     value: \.joinMembers,
                                                     to: updatedCurrentMembers)
                    do {
                        // currentComm에 가입신청 지우는 업데이트
                        try await firebaseManager.update(data: currentComm,
                                                         value: \.waitApprovalMemberIDs,
                                                         to: updatedWaitList)
                        PushNotificationManager.shared.sendPushNotification(
                            toFCMToken: user.fcmToken,
                            title: "\(currentComm.name)",
                            body: "\(currentComm.name)의 가입신청이 수락됐어요!"
                        )
                    } catch {
                        print(#function + "커뮤니티 Document에 waitApprovalMemberIDs 업데이트 실패")
                    }
                } catch {
                    print(#function + "커뮤니티 Document에 joinMembers 업데이트 실패")
                }
            } catch {
                print(#function + "가입한 유저 Document에 commInfoList 업데이트 실패")
            }
        }
    }
    /// 매니저가 유저를 추방하는 함수
    func deportMember(user: User) async {
        if isCurrentCommManager {
            guard let currentComm else { return }
            let updatedJoinMembers = currentComm.joinMembers.filter { $0.id != user.id }
            let deportedMembersComm = user.commInfoList.filter({ $0.id != currentComm.id })
            do {
                // 추방한 유저의 currentComm이 제외된 commInfoList 업데이트
                try await firebaseManager.update(data: user,
                                                 value: \.commInfoList,
                                                 to: deportedMembersComm)
                do {
                    // currentComm에 추방한 유저가 제외된 joinMembers 업데이트
                    try await firebaseManager.update(data: currentComm,
                                                     value: \.joinMembers,
                                                     to: updatedJoinMembers)
                    PushNotificationManager.shared.sendPushNotification(
                        toFCMToken: user.fcmToken,
                        title: "\(currentComm.name)",
                        body: "\(currentComm.name)에서 추방당했어요...🥲"
                    )
                } catch {
                    print(#function + "내보낸 유저 Document에 commInfoList 업데이트 실패")
                }
            } catch {
                print(#function + "커뮤니티 Document에 joinMembers 업데이트 실패")
            }
        }
    }
    /// 커뮤니티의 설정(이미지, 이름, 설명, 검색여부)를 업데이트하는 함수
    func updateCommInfo(comm: Community, image: UIImage?) async {
        do {
            if let image {
                try await firebaseManager.createWithImage(data: comm, image: image)
            } else {
                try await firebaseManager.create(data: comm)
            }
        } catch {
            print(#function + "Community Collection에 업데이트 실패")
        }
    }
    /// 새로운 커뮤니티를 생성하는 함수
    @MainActor
    func createComm(comm: Community, image: UIImage?) async -> Community? {
        guard let currentUser else { return nil }
        let createAt = Date().timeIntervalSince1970
        var newComm = comm
        newComm.id = UUID().uuidString
        newComm.managerID = currentUser.id
        newComm.createdAt = createAt
        newComm.joinMembers = [.init(id: currentUser.id, joinedAt: createAt)]
        do {
            if let image {
                // 사진이 있는 커뮤니티 생성
                try await firebaseManager.createWithImage(data: newComm, image: image)
            } else {
                // 사진이 없는 커뮤니티 생성
                try await firebaseManager.create(data: newComm)
            }
            do {
                // currentUser에 생성한 커뮤니티 정보 업데이트
                try await firebaseManager.update(data: currentUser,
                                                 value: \.commInfoList,
                                                 to: currentUser.commInfoList + [.init(id: newComm.id)])
            }
            setCurrentID(id: newComm.id)
            return newComm
        } catch {
            print(#function + "새 Community Collection에 추가 실패")
            return nil
        }
    }
    /// 그룹 멤버가 그룹을 나갈 때 커뮤니티에서 나갈 멤버의 정보를 지우고 커뮤니티의 모든 유저정보를 받아와 해당 커뮤니티의 버디리스트에서 탈퇴한 유저를 지워서 업데이트하는 함수
    @MainActor
    func leaveComm() async {
        guard let currentComm,
              let currentUser
        else { return }

        let changedMembers = currentComm.joinMembers.filter({ $0.id != currentUser.id })
        let changedUserCommList = currentUser.commInfoList.filter({ $0.id != currentComm.id })
        do {
//            1. [v] currentComm의 commInfoList에서 해당 currentUser정보지우기
            try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: changedUserCommList)
//            2. [v] currentUser의 commInfoList에서 해당 currentComm정보지우기
            try await firebaseManager.update(data: currentComm, value: \.joinMembers, to: changedMembers)
//            3. [v] currentComm의 joinedMembers에 해당하는 User Document를 받아오고 유저들의 commInfoList중 id가 currentComm.id와 같은 User.JoinedCommInfo에서 buddyList가 currentUser.id를 포함하고 있으면 지우고 업데이트
            let results = await firebaseManager.readDocumentsWithIDs(type: User.self,
                                                                     ids: changedMembers.map({ $0.id }))
            await results.asyncForEach { [weak self] result in
                switch result {
                case .success(let success):
                    guard var updatedCommInfo = success.commInfoList
                        .first(where: { $0.id == currentComm.id }) else { return }
                    if updatedCommInfo.buddyList.contains(currentUser.id) {
                        do {
                            updatedCommInfo.buddyList = updatedCommInfo.buddyList.filter({ $0 != currentUser.id })
                            guard let index = success.commInfoList.firstIndex(where: { $0.id == updatedCommInfo.id }) else { return }
                            var updatedCommInfolist = success.commInfoList
                            updatedCommInfolist[index] = updatedCommInfo
                            try await self?.firebaseManager.update(data: success, value: \.commInfoList, to: updatedCommInfolist)
                        } catch {
                            print(#function + "탈퇴한 유저를 buddyList에 가진 User의 commInfoList 업데이트 실패")
                        }
                    }
                case .failure:
                    break
                }
            }
//            4. [ ] Firebase의 Alarm 컬렉션에서 currentUser.id == receiveUserID && currentComm == communityID 조건 찾아서 알람 지우기
            await deleteAlarm(user: currentUser, comm: currentComm)
			print("👩🏻‍🤝‍👨🏼현재 joinedComm: \(joinedComm)")
			print("👩🏻‍🤝‍👨🏼현재 currentComm: \(currentComm)")
            guard let firstComm = joinedComm.first else { return }
            setCurrentID(id: firstComm.id)
        } catch {
            print(#function + "Community의 Members 업데이트 실패")
        }
    }
    /// 인자로 들어온 커뮤니티에서 유저가 받은 알람을 지우는 메서드
    func deleteAlarm(user: User, comm: Community) async {
        var alarms: [Alarm] = []
        let results = await firebaseManager.readDocumentsWithValues(type: Alarm.self, keyPath1: \.communityID, value1: comm.id, keyPath2: \.showUserID, value2: user.id)
        alarms.append(contentsOf: results)
        await alarms.asyncForEach {
            do {
                try await self.firebaseManager.delete(data: $0)
            } catch {
                print(#function + "\($0) 지우기 실패")
            }
        }
    }
    /// [가입신청] 그룹에 가입신청 보내는 함수
    func requestJoinComm(comm: Community) async throws {
        guard let currentUser else { return }
		do {
            // 해당 커뮤니티의 최신 정보를 가져와 가입신청 리스트에 로그인된 유저를 추가해 업데이트
			let result = try await firebaseManager.read(type: Community.self, id: comm.id).get()
			
			do {
				try await firebaseManager.update(data: currentUser, value: \.requestComm, to: currentUser.requestComm + [comm.id])
			} catch {
				print(#function + "유저의 가입신청 정보 업데이트 실패")
			}
			
			try await firebaseManager.update(data: comm.self,
											 value: \.waitApprovalMemberIDs,
											 to: result.waitApprovalMemberIDs + [currentUser.id])
			
            
            // 해당 커뮤니티의 매니저에게 푸시 노티 발사
            let managerInfoResult = await firebaseManager.read(type: User.self, id: comm.managerID)
            switch managerInfoResult {
            case .success(let success):
                PushNotificationManager.shared.sendPushNotification(
                    toFCMToken: success.fcmToken,
                    title: "\(comm.name)",
                    body: "\(currentUser.name) 님이 \(comm.name) 그룹에 가입신청했어요!"
                )
            case .failure:
                print(#function + "가입신청시 매니저 정보 불러오기 실패")
            }
		} catch {
			print(#function + "🔴 그룹 가입 신청 실패")
		}
    }
	
    // MARK: - DeepLink
    
    /// 딥링크 url의 정보를 구분해 처리하는 함수
    /// 1. 가입되어 있을 때: 그룹탭으로 이동해 링크의 커뮤니티를 보여줌
    /// 2. 가입되어 있지않을 때
    ///
    ///     a. 올바른 커뮤니티: 가입화면을 띄워줌
    ///     b. 존재하지 않는 커뮤니티: 경고화면을 띄워줌
    @MainActor
    func handleInviteURL(_ url: URL) async {
        guard let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String else { return }
        guard url.scheme == "kakao\(kakaoKey)" else {
            await tempHandleInviteURL(url)
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("유효하지 않은 URL")
            return
        }
        guard let action = components.host, action == "kakaolink" else {
            print("유효하지 않은 URL action")
            return
        }
        guard let commID = components.queryItems?.first(where: { $0.name == "commID" })?.value else {
            print("유효하지 않은 URL value")
            return
        }
        if let currentUser {
            isShowingSearchCommSheet = false
            isShowingCommListSheet = false
            if currentUser.commInfoList.contains(where: { $0.id == commID }) {
                guard let comm = joinedComm.first(where: { $0.id == commID }) else { return }
                self.setCurrentID(id: comm.id)
            } else {
                Task {
                    let result = await firebaseManager.read(type: Community.self, id: commID)
                    switch result {
                    case let .success(success):
                        deepLinkTargetComm = success
                        isJoinWithDeeplinkView = true
                    case .failure:
                        isDeepLinkExpired = true
                        print("딥링크 커뮤니티 아이디 찾을 수 없음: \(commID)")
                    }
                }
            }
        } else {
            deepLinkHandler = {
                guard let currentUser = self.currentUser else { return }
                self.isShowingSearchCommSheet = false
                self.isShowingCommListSheet = false
                if currentUser.commInfoList.contains(where: { $0.id == commID }) {
                    guard let comm = self.joinedComm.first(where: { $0.id == commID }) else { return }
                    self.setCurrentID(id: comm.id)
                } else {
                    Task {
                        let result = await self.firebaseManager.read(type: Community.self, id: commID)
                        switch result {
                        case let .success(success):
                            self.deepLinkTargetComm = success
                            self.isJoinWithDeeplinkView = true
                        case .failure:
                            self.isDeepLinkExpired = true
                            print("딥링크 커뮤니티 아이디 찾을 수 없음: \(commID)")
                        }
                    }
                }
            }
        }
    }
    /// 딥링크로 초대된 커뮤니티에 가입하는 함수
    @MainActor
    func joinCommWithDeeplink() async {
        guard let currentUser else { return }
        let newMember = Community.Member(id: currentUser.id, joinedAt: Date().timeIntervalSince1970)
        do {
            // 커뮤니티에 로그인된 유저를 추가
            try await firebaseManager.update(data: deepLinkTargetComm, value: \.joinMembers, to: deepLinkTargetComm.joinMembers + [newMember])
            do {
                // 로그인된 유저에 커뮤니티 정보 추가
                try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: currentUser.commInfoList + [.init(id: deepLinkTargetComm.id)])
                setCurrentID(id: deepLinkTargetComm.id)
            } catch {
                print(#function + "딥링크 가입시 유저의 commInfoList 업데이트 실패")
            }
            // 매니저에게 푸시노티 발사
            let result = await firebaseManager.read(type: User.self, id: deepLinkTargetComm.managerID)
            switch result {
            case .success(let success):
                PushNotificationManager.shared.sendPushNotification(
                    toFCMToken: success.fcmToken,
                    title: "\(deepLinkTargetComm.name)",
                    body: "\(currentUser.name) 님이 \(deepLinkTargetComm.name) 그룹에 링크로 가입했어요!"
                )
                deepLinkTargetComm = .emptyComm
            case .failure:
                print(#function + "딥링크 가입시 매니저 정보 불러오기 실패")
            }
        } catch {
            print(#function + "딥링크 가입시 커뮤니티의 joinMembers 업데이트 실패")
        }
    }
    /// 카카오톡앱에 currentComm 초대링크 공유
    func inviteWithKakao() {
        guard let currentComm,
              let currentUser
        else { return }
        let link = Link(iosExecutionParams: ["commID": "\(currentCommID)"])
        
        // 버튼들 입니다.
        let webButton = Button(title: "제노앱에서 보기", link: link)
        
        guard let zenoImgURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/zeno-8cf4b.appspot.com/o/ZenoAppIcon.png?alt=media&token=267e57e0-bbf4-4864-874d-e79c61770fe2&_gl=1*14qx05*_ga*MTM1OTM4NTAwNi4xNjkyMzMxODc2*_ga_CW55HF8NVT*MTY5NzQ2MDgyMS4xMDIuMS4xNjk3NDYwODc2LjUuMC4w") else { return }
        let content = Content(title: currentComm.name,
                              imageUrl: URL(string: currentComm.imageURL ?? " ") ?? zenoImgURL,
                              description: "\(currentUser.name)님이 \(currentComm.name)에 초대했어요!",
                              link: link)
        let template = FeedTemplate(content: content, buttons: [webButton])
        // 메시지 템플릿 encode
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
            // 생성한 메시지 템플릿 객체를 jsonObject로 변환
            if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                // 카카오톡 앱이 있는지 체크합니다.
                if ShareApi.isKakaoTalkSharingAvailable() {
                    ShareApi.shared.shareDefault(templateObject: templateJsonObject) { linkResult, error in
                        if let error {
                            print("error : \(error)")
                        } else {
                            print("defaultLink(templateObject:templateJsonObject) success.")
                            guard let linkResult = linkResult else { return }
                            UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                        }
                    }
                } else {
                    // 없을 경우 카카오톡 앱스토어로 이동합니다. (이거 하려면 URL Scheme에 itms-apps 추가 해야함)
                    let url = "itms-apps://itunes.apple.com/app/362057947"
                    if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Snapshot
    /// userSnapshot을 연결하는 함수
    func setUserSnapshot(id: String, forAlarmFunc: @escaping () -> Void = {}) {
        print("📝", #function)
        guard !id.isEmpty else { return }
        userListener = Firestore.firestore().collection("User").document(id).addSnapshotListener { [weak self] snapshot, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            let user = try? snapshot?.data(as: User.self)
            self?.userListenerHandler(user: user) {
                forAlarmFunc()
            }
        }
    }
    /// userSnapshot와 로그인된 유저에게 필요한 요소들을 제거하는 함수
    func logout() {
        userListener?.remove()
        userListener = nil
        currentUser = nil
        joinedComm = []
        removeCurrentCommSnapshot()
        currentCommID.removeAll()
        isFetchComplete = false
    }
    /// commSnapshot을 연결하는 함수
    func addCurrentCommSnapshot(forAlarmFunc: @escaping () -> Void = {}) {
        guard let currentUser else { return }
        print("📝", #function)
        if currentCommID.isEmpty {
            print("📝 currentCommID 비었음 currentUser: \(currentUser.commInfoList)", #function)
            guard let defaultComm = currentUser.commInfoList.first
            else {
                // 그룹정보가 존재하지 않을때도 alarmVM.fetchAlarmPagenation을 실행해주어 isFetchedAlarm값을 true로 받아간다.
                forAlarmFunc()
				isFetchComplete = true
                return
            }
            currentCommID = defaultComm.id
        }
        
        commListener = Firestore.firestore().collection("Community").document(currentCommID)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                guard let currentUser = self?.currentUser,
                      let comm = try? snapshot?.data(as: Community.self)
                else { return }
                if currentUser.commInfoList.contains(where: { $0.id == comm.id }) {
                    print("📝4", #function)
                    self?.setCurrentID(id: comm.id)
                    self?.updateCurrentComm(comm: comm) {
                        forAlarmFunc()
                    }
                } else {
                    print("📝5", #function)
                    self?.setCurrentID()
                    self?.updateCurrentComm()
                }
        }
    }
    /// commSnapshot을 제거하는 함수
    func removeCurrentCommSnapshot() {
        commListener?.remove()
        commListener = nil
        currentComm = nil
    }
    /// 로그인된 유저를 변경하며 로그인된 유저가 없을 때 snapshot을 겁니다
    /// user가 가입한 커뮤니티가 없다면 currentCommID를 빈문자열로 만들어 가입된 커뮤니티가 없게 표시합니다
    private func loginCurrentUser(user: User?, forAlarmFunc: @escaping () -> Void = {}) {
        currentUser = user
        addCurrentCommSnapshot {
            forAlarmFunc()
        }
    }
    /// currentUser의 정보를 업데이트 하는 함수
    private func updateCurrentUser(user: User) {
        guard let currentUser else { return }
        guard user.commInfoList.map({ $0.id }) == currentUser.commInfoList.map({ $0.id }) else {
            Task {
                await MainActor.run {
                    self.currentUser = user
                }
                await fetchJoinedComm()
            }
            return
        }
        switch user.commInfoList.isEmpty {
        case true:
            setCurrentID()
        case false:
            if currentCommID.isEmpty {
                if let firstItem = user.commInfoList.first {
                    print("📝2", #function)
                    setCurrentID(id: firstItem.id)
                }
            }
        }
        self.currentUser = user
    }
    /// userListener의 업데이트가 첫번째 로그인인지 정보 변경인지 나뉘는 분기
    func userListenerHandler(user: User?, forAlarmFunc: @escaping () -> Void = {}) {
        print("📝", #function)
        switch currentUser {
        case .none:
            loginCurrentUser(user: user, forAlarmFunc: forAlarmFunc)
        case .some:
            guard let user else { return }
            updateCurrentUser(user: user)
        }
    }
    /// 현재 표시되는 커뮤니티를 변경하며 커뮤니티의 유저 리스트를 받아옵니다
    func updateCurrentComm(comm: Community? = nil, forAlarmFunc: @escaping () -> Void = {}) {
        currentComm = comm
        Task {
            print("📝", #function)
            await fetchJoinedComm {
                forAlarmFunc()
            }
        }
    }
    /// 현재 표시되는 커뮤니티의 ID를 변경하는 함수, 기본값은 빈 문자열입니다
    /// 인자로 들어온 값이 새로운 값일때만 snapshot을 끊고 새로운 커뮤니티에 snapshot을 겁니다
    func setCurrentID(id: Community.ID = "") {
        if currentCommID != id {
            currentCommID = id
            removeCurrentCommSnapshot()
            addCurrentCommSnapshot()
        }
    }
    
    // MARK: fetch
    /// user정보로 커뮤니티를 받아오는 함수
    @MainActor
    func fetchJoinedComm(alarmFunc: @escaping () -> Void = {}) async {
        guard let currentUser else { return }
        print("📝", #function)
        print(#function + "실행중")
        let results = await firebaseManager.readDocumentsWithIDs(
            type: Community.self,
            ids: currentUser.commInfoList.map { $0.id }
        )
        let joinedComm = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.joinedComm = joinedComm
        await self.fetchCurrentCommMembers()
        if isCurrentCommManager {
            await self.fetchWaitedMembers()
        }
        print("📝 joinedComm 패치완료")
        alarmFunc() // alarmVM.fetchAlarmPagenation 이 실행된다. (현재 의도 23.10.20)
		isFetchComplete = true
        deepLinkHandler()
    }
    /// 선택된 커뮤니티에 가입된 유저를 받아오는 함수
    @MainActor
    func fetchCurrentCommMembers() async {
        // 1. 파베에서 현재 그룹 정보 불러오기
        let resultComm = await firebaseManager.read(type: Community.self, id: currentCommID.description)
        do {
            let fetchComm = try resultComm.get()
            // 2. 현재 그룹 유저 ID 나누기
            let currentCommMemberIDs = fetchComm.joinMembers.map { $0.id }
            // 3. 유저 ID로 유저객체값 받기
            let results = await firebaseManager.readDocumentsWithIDs(
                type: User.self,
                ids: currentCommMemberIDs
            )
            // 4. result의 유저객체값 분류
            let currentMembers = results.compactMap {
                switch $0 {
                case .success(let success):
                    return success
                case .failure:
                    return nil
                }
            }
            // 5. 현재 그룹의 유저정보에 뿌려주기
            self.currentCommMembers = exceptCurrentUser(currentMembers)
                .filter { currentCommMemberIDs.contains($0.id) }
        } catch {
            print("🔴 현재 커뮤니티 유저 정보 불러오기 실패")
        }
    }
    /// 선택된 커뮤니티에 가입신청된 유저를 받아오는 함수
    @MainActor
    func fetchWaitedMembers() async {
        // 1. 파베에서 현재 그룹 정보 불러오기
        let resultComm = await firebaseManager.read(type: Community.self, id: currentCommID.description)
        print("📝", #function)
        do {
            if isCurrentCommManager {
                let fetchComm = try resultComm.get()
                // 3. 유저 ID로 유저객체값 받기
                let results = await firebaseManager.readDocumentsWithIDs(
                    type: User.self,
                    ids: fetchComm.waitApprovalMemberIDs
                )
                // 4. result의 유저객체값 분류
                let waitUsers = results.compactMap {
                    switch $0 {
                    case .success(let success):
                        return success
                    case .failure:
                        return nil
                    }
                }
                // 5. 현재 그룹의 가입신청 유저정보에 뿌려주기
                self.currentWaitApprovalMembers = waitUsers
                    .filter { fetchComm.waitApprovalMemberIDs.contains($0.id) }
                print(#function + "🔵📝 현재 지원한 멤버 \(self.currentWaitApprovalMembers.map { $0.name })")
            }
        } catch {
            print("🔴 현재 커뮤니티 유저 정보 불러오기 실패")
        }
    }
    
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    
    // MARK: Legacy
    
    /// 시뮬레이터용 초대링크를 복사할 수 있는 ShareSheet를 띄워줌
    @MainActor
    private func tempHandleInviteURL(_ url: URL) async {
        guard url.scheme == "zenoapp" else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("유효하지 않은 URL")
            return
        }
        guard let action = components.host, action == "kakaolink" else {
            print("유효하지 않은 URL action")
            return
        }
        guard let commID = components.queryItems?.first(where: { $0.name == "commID" })?.value else {
            print("유효하지 않은 URL value")
            return
        }
        if let currentUser {
            isShowingSearchCommSheet = false
            isShowingCommListSheet = false
            if currentUser.commInfoList.contains(where: { $0.id == commID }) {
                guard let comm = joinedComm.first(where: { $0.id == commID }) else { return }
                self.setCurrentID(id: comm.id)
            } else {
                Task {
                    let result = await firebaseManager.read(type: Community.self, id: commID)
                    switch result {
                    case let .success(success):
                        deepLinkTargetComm = success
                        isJoinWithDeeplinkView = true
                    case .failure:
                        isDeepLinkExpired = true
                        print("딥링크 커뮤니티 아이디 찾을 수 없음: \(commID)")
                    }
                }
            }
        } else {
            deepLinkHandler = {
                guard let currentUser = self.currentUser else { return }
                self.isShowingSearchCommSheet = false
                self.isShowingCommListSheet = false
                if currentUser.commInfoList.contains(where: { $0.id == commID }) {
                    guard let comm = self.joinedComm.first(where: { $0.id == commID }) else { return }
                    self.setCurrentID(id: comm.id)
                } else {
                    Task {
                        let result = await self.firebaseManager.read(type: Community.self, id: commID)
                        switch result {
                        case let .success(success):
                            self.deepLinkTargetComm = success
                            self.isJoinWithDeeplinkView = true
                        case .failure:
                            self.isDeepLinkExpired = true
                            print("딥링크 커뮤니티 아이디 찾을 수 없음: \(commID)")
                        }
                    }
                }
            }
        }
    }
    /// 시뮬레이터용 ShareSheet 올리기
    func tempShareLink() {
        guard let commID = currentComm?.id else { return }
        let deepLink = "zenoapp://kakaolink?commID=\(commID)"
        let activityVC = UIActivityViewController(
            activityItems: [deepLink],
            applicationActivities: [KakaoActivity(), IGActivity()]
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let mainWindow = windowScene.windows.first {
                mainWindow.rootViewController?.present(
                    activityVC,
                    animated: true,
                    completion: {
//                        print("공유창 나타나면서 할 작업들?")
                    }
                )
            }
        }
    }
    
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
}
// MARK: 테스트용 코드
enum UserStatus {
    case unSign
    case signIn(JoinedCommStatus)
}

enum JoinedCommStatus {
    case unJoined
    case joined
    case empty
}

struct TestUser : Identifiable, Hashable, Codable, FirebaseAvailable, ZenoProfileVisible {
    var id: String = UUID().uuidString
    /// 이름
    var name: String
    /// 성별
    var gender: Gender
    /// 프로필 이미지
    var imageURL: String?
    /// 한줄 소개
    var description: String = ""
    /// 카카오 로그인 시 생성된 토큰 저장 용도
    var kakaoToken: String
    /// 푸쉬 알람을 위해 현재 유저에게 발급된 token
    var fcmToken: String?
    /// 잔여 코인 횟수
    var coin: Int
    /// 메가폰 잔여 횟수
    var megaphone: Int
    /// 초성보기 사용권 잔여 횟수
    var showInitial: Int
    /// 제노 끝나는 시간
    var zenoEndAt: Double?
    /// 커뮤니티id, 친구관계, 커뮤니티알람
    var commInfoList: [joinedCommInfo] = []
    /// 가입신청한 커뮤니티 id
    var requestComm: [DocumentReference]
    /// 제노 시작 시간
    var ZenoStartAt: Double = Date().timeIntervalSince1970

    struct joinedCommInfo: Hashable, Codable {
        var comm: DocumentReference
        var buddyList: [DocumentReference] = []
        var alert: Bool = true
    }
}

func fetchJoinedComm(user: TestUser) async -> [Community] {
    var comms: [Community] = []
    await user.commInfoList.asyncForEach {
        do {
            let comm = try await $0.comm.getDocument(as: Community.self)
            comms.append(comm)
        } catch {
            
        }
    }
    return comms
}
