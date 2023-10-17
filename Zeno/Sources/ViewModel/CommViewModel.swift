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

class CommViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private let commRepo = CommRepository.shared
    /// App단에서 UserViewModel.currentUser가 변경될 때 CommViewModel.currentUser를 받아오는 함수로 유저 정보를 공유함
    private(set) var currentUser: User?
    /// 마지막으로 선택한 커뮤니티의 ID를 UserDefaults에 저장
    @AppStorage("selectedCommID") var currentCommID: Community.ID = ""
    /// Firebase의 커뮤니티 Collection에 있는 모든 커뮤니티
    @Published var allComm: [Community] = []
    /// currentUser가 가입한 모든 커뮤니티
    @Published var joinedComm: [Community] = []
    /// currentUser가 마지막으로 선택한 커뮤니티, 가입된 커뮤니티가 없으면 nil을 반환
    var currentComm: Community? {
        if !joinedComm.isEmpty {
            guard let currentComm = joinedComm.getCurrent(id: currentCommID) else {
                return joinedComm.first
            }
            return currentComm
        }
        return nil
    }
    /// 선택된 커뮤니티의 모든 유저(본인 포함)
    @Published var currentCommMembers: [User] = []
    /// 선택된 커뮤니티의 가입 대기중인 유저
    @Published var currentWaitApprovalMembers: [User] = []
	/// [커뮤니티최근검색] 최근 검색된 검색어들
	@Published var recentSearches: [String] = []
	/// [매니저 위임] 매니저 바뀌었을 때 알람
	@Published var managerChangeWarning: Bool = false
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
            .filter { $0.isSearchable }
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
    @Published var deepLinkTargetComm: Community = .emptyComm
    /// 딥링크 수신 정상 처리에 따라 가입하는 View를 보여주는 Bool
    @Published var isJoinWithDeeplinkView: Bool = false
    @Published var isDeepLinkExpired: Bool = false
    @Published var isShowingSearchCommSheet: Bool = false
    @Published var isShowingCommListSheet: Bool = false
    
    init() {
        Task {
            await fetchAllComm()
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
        currentUser = user
        joinedComm = allComm.filterJoined(user: user)
    }
    /// 선택된 커뮤니티 Index를 변경하는 함수
    func setCurrentID(id: Community.ID) {
        currentCommID = id
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
	
	/// [커뮤니티최근검색] 최신화된 유저디폴트 불러오기
	private func loadRecentSearches() {
		if let savedSearches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
			recentSearches = savedSearches
		}
	}
    
    /// 딥링크 url의 정보를 구분해 초대받은 커뮤니티에 가입되어 있다면 해당 커뮤니티를 보여주고 가입되어 있지 않다면 가입할 수 있는 Modal View를 띄워주는 함수
    @MainActor
    func handleInviteURL(_ url: URL) async {
        guard let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String else { return }
        guard url.scheme == "kakao\(kakaoKey)" else { return }
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
        guard let currentUser else { return }
        isShowingSearchCommSheet = false
        isShowingCommListSheet = false
        if currentUser.commInfoList.contains(where: { $0.id == commID }) {
            guard let comm = joinedComm.first(where: { $0.id == commID }) else { return }
            setCurrentID(id: comm.id)
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
    }
    /// 딥링크로 초대된 커뮤니티에 가입하는 함수
    @MainActor
    func joinCommWithDeeplink() async {
        guard let currentUser else { return }
        let newMember = Community.Member(id: currentUser.id, joinedAt: Date().timeIntervalSince1970)
        let newCommMembers = deepLinkTargetComm.joinMembers + [newMember]
        do {
            try await firebaseManager.update(data: deepLinkTargetComm, value: \.joinMembers, to: newCommMembers)
            guard let index = allComm.firstIndex(where: { $0.id == deepLinkTargetComm.id }) else { return }
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
                        let removedRequests = user.requestComm.filter { $0 != currentComm.id }
                        do {
                            try await self?.firebaseManager.update(data: user, value: \.requestComm, to: removedRequests)
                        } catch {
                            print(#function + "커뮤니티 삭제 후 \(user.id)에서 commInfoList의 삭제 된 커뮤니티 정보 제거 실패")
                        }
                    case .failure:
                        print(#function + "삭제 된 커뮤니티의 waitApprovalMembers의 id가 User Collection에서 Document 찾기 실패함")
                    }
                }
                guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id })
                else { return }
                allComm.remove(at: commIndex)
                joinedComm = allComm.filterJoined(user: currentUser)
            } catch {
                print(#function + "그룹 삭제 실패")
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
                    do {
                        let newCommInfo = user.commInfoList + [.init(id: currentComm.id, buddyList: [], alert: true)]
                        try await firebaseManager.update(data: user, value: \.commInfoList, to: newCommInfo)
                        guard let commIndex = allComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
                        allComm[commIndex].waitApprovalMemberIDs = updatedWaitList
                        allComm[commIndex].joinMembers = updatedCurrentMembers
                    } catch {
                        print(#function + "가입한 유저 Document에 commInfoList 업데이트 실패")
                    }
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
        allComm = communities
    }
    /// 커뮤니티의 설정(이미지, 이름, 설명, 검색여부)를 업데이트하는 함수
    @MainActor
    func updateCommInfo(comm: Community, image: UIImage?) async {
        do {
            if let image {
                let changedComm = try await firebaseManager.createWithImage(data: comm, image: image)
                guard let index = joinedComm.firstIndex(where: { $0.id == changedComm.id }) else { return }
                joinedComm[index] = changedComm
            } else {
                try await firebaseManager.create(data: comm)
                guard let index = joinedComm.firstIndex(where: { $0.id == comm.id }) else { return }
                joinedComm[index] = comm
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
                newComm = try await firebaseManager.createWithImage(data: newComm, image: image)
            } else {
                try await firebaseManager.create(data: newComm)
            }
            allComm.append(newComm)
            joinedComm.append(newComm)
            setCurrentID(id: newComm.id)
            return newComm
        } catch {
            print(#function + "새 Community Collection에 추가 실패")
            return nil
        }
    }
    /// 선택된 커뮤니티에 가입된 유저, 가입신청된 유저를 받아오는 함수
    @MainActor
	func fetchCurrentCommMembers() async {
		// 1. 파베에서 현재 그룹 정보 불러오기
		let resultComm = await firebaseManager.read(type: Community.self, id: currentCommID.description)
		
		do {
			let fetchComm = try resultComm.get()
			// 2. 현재 그룹 유저 ID 나누기
			let currentCommMemberIDs = fetchComm.joinMembers.map { $0.id }
			let currentWaitMemberIDs = fetchComm.waitApprovalMemberIDs
			// 3. 유저 ID로 유저객체값 받기
			let results = await firebaseManager.readDocumentsWithIDs(type: User.self,
																	 ids: currentCommMemberIDs + currentWaitMemberIDs)
			// 4. result의 유저객체값 분류
			let currentUsers = results.compactMap {
				switch $0 {
				case .success(let success):
					return success
				case .failure:
					return nil
				}
			}
			// 5. 현재 그룹의 유저정보에 뿌려주기
			self.currentCommMembers = exceptCurrentUser(users: currentUsers)
				.filter { currentCommMemberIDs.contains($0.id) }
			if isCurrentCommManager {
				self.currentWaitApprovalMembers = exceptCurrentUser(users: currentUsers)
					.filter { currentWaitMemberIDs.contains($0.id) }
				print(#function + "🔵 현재 지원한 멤버 \(self.currentWaitApprovalMembers.map { $0.name })")
			}
		} catch {
			print("🔴 현재 커뮤니티 유저 정보 불러오기 실패")
		}
    }
    /*
     1. [v] currentComm의 commInfoList에서 해당 currentUser정보지우기
     2. [ ] currentUser의 commInfoList에서 해당 currentComm정보지우기
     3. [v] currentComm의 joinedMembers에 해당하는 User Document를 받아오고 유저들의 commInfoList중 id가 currentComm.id와 같은 User.JoinedCommInfo에서 buddyList가 currentUser.id를 포함하고 있으면 지우고 업데이트
     4. [V] Firebase의 Alarm 컬렉션에서 currentUser.id == receiveUserID && currentComm == communityID 조건 찾아서 알람 지우기
     5. [ ] 로컬 업데이트
     */
    /// 그룹 멤버가 그룹을 나갈 때 커뮤니티에서 나갈 멤버의 정보를 지우고 커뮤니티의 모든 유저정보를 받아와 해당 커뮤니티의 버디리스트에서 탈퇴한 유저를 지워서 업데이트하는 함수
    @MainActor
    func leaveComm() async {
        guard let currentComm,
              let currentUser
        else { return }
        let changedMembers = currentComm.joinMembers.filter({ $0.id != currentUser.id })
        do {
            try await firebaseManager.update(data: currentComm, value: \.joinMembers, to: changedMembers)
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
            // 로컬 업데이트
            guard let index = joinedComm.firstIndex(where: { $0.id == currentComm.id }) else { return }
            joinedComm.remove(at: index)
            guard let firstComm = joinedComm.first else { return }
            setCurrentID(id: firstComm.id)
        } catch {
            print(#function + "Community의 Members 업데이트 실패")
        }
    }
    /// [가입신청] 그룹에 가입신청 보내는 함수
    @MainActor
    func requestJoinComm(comm: Community) async throws {
        guard let currentUser else { return }
		do {
			let result = try await firebaseManager.read(type: Community.self, id: comm.id).get()
			let newComm = result.waitApprovalMemberIDs + [currentUser.id]
			
			try await firebaseManager.update(data: comm.self,
											 value: \.waitApprovalMemberIDs,
											 to: newComm)
			guard let index = allComm.firstIndex(where: { $0.id == comm.id }) else { return }
			allComm[index].waitApprovalMemberIDs = newComm
		} catch {
			print(#function + "🔴 그룹 가입 신청 실패")
		}
    }
    /// 카카오톡앱에 currentComm 초대링크 공유
    func kakao() {
        guard let currentComm,
              let currentUser
        else { return }
        let link = Link(iosExecutionParams: ["commID": "\(currentCommID)"])
        
        // 버튼들 입니다.
        let webButton = Button(title: "제노앱에서 보기", link: link)
        
        guard let zenoImgURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/zeno-8cf4b.appspot.com/o/ZenoAppIcon.png?alt=media&token=267e57e0-bbf4-4864-874d-e79c61770fe2&_gl=1*14qx05*_ga*MTM1OTM4NTAwNi4xNjkyMzMxODc2*_ga_CW55HF8NVT*MTY5NzQ2MDgyMS4xMDIuMS4xNjk3NDYwODc2LjUuMC4w") else { return }
        let content = Content(title: currentComm.name,
                              imageUrl: zenoImgURL,
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
    /// ShareSheet 올리기
    func shareText() {
        guard let commID = currentComm?.id,
              let kakaoKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String
        else { return }
        let deepLink = "kakaod\(kakaoKey)://kakaolink=\(commID)"
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
	/// [그룹 메인 뷰] 현재 커뮤니티의 매니저인지 확인
	func checkManagerUser(user: User) -> Bool {
		guard let managerID = currentComm?.managerID.description else { return false }
		return managerID == user.id
	}
}
