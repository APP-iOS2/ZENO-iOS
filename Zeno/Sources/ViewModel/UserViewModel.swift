//
//  AuthService.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

final class UserViewModel: ObservableObject, LoginStatusDelegate {
    func logout() async { }
    func memberRemove() async -> Bool { return false }
    
    /// 파이어베이스 Auth의 User
    @Published var userSession: FirebaseAuth.User?
    /// 현재 로그인된 유저
    @Published var currentUser: User?    
    @Published var isNickNameRegistViewPop: Bool = false   // 회원가입창 열림 여부
    /* userViewModel의 currentUser가 변경되었지만 alarmViewModel의 정보가 변경되기 이전에 isNeedLogin이 변경되어
    AlarmView에 순간적으로 가입된 커뮤니티가 없습니다가 뜨는 버그있음 */

    private let firebaseManager = FirebaseManager.shared
    private let coolTime: Int = 7
    
    @MainActor
    init() {
        print("🦕userViewModel 초기화")
        Task {
            try? await loadUserData() // currentUser Value 가져오기 서버에서
            if self.currentUser == nil {
                SignStatusObserved.shared.isNeedLogin = true // signIn상태가 아닌데 currentUser값을 가져오지 못하면 로그인이 필요함. (로그인창 이동)
            } else {
                SignStatusObserved.shared.isNeedLogin = false
            }
        }
    }

    /// LoginStatusDelegate 프로토콜 메서드
    @MainActor
    func login() async -> Bool {
        print("✔️ userVM login")
        return await self.startWithKakao()
    }
    
    /// 이메일 로그인
    @MainActor
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try? await loadUserData()
            print("🔵 로그인 성공")
        } catch let error as NSError {
            switch AuthErrorCode.Code(rawValue: error.code) {
            case .wrongPassword:  // 잘못된 비밀번호
                break
            case .userTokenExpired: // 사용자 토큰 만료 -> 사용자가 다른 기기에서 계정 비밀번호를 변경했을수도 있음. -> 재로그인 해야함.
                break
            case .tooManyRequests: // Firebase 인증 서버로 비정상적인 횟수만큼 요청이 이루어져 요청을 차단함.
                break
            case .userNotFound: // 사용자 계정을 찾을 수 없음.
                break
            case .networkError: // 작업 중 네트워크 오류 발생
                break
            default:
                break
            }
            print("🔴 로그인 실패. 에러메세지: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func addFriend(user: User, comm: Community) async {
        guard let currentUser,
              let index = currentUser.commInfoList.firstIndex(where: { $0.id == comm.id }) else { return }
        var newInfo = currentUser.commInfoList
        newInfo[index].buddyList.append(user.id)
        do {
            try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: newInfo)
            self.currentUser?.commInfoList = newInfo
        } catch {
            print(#function + "User Document에 commInfoList 업데이트 실패")
        }
    }
    
    @MainActor
    func joinCommWithDeeplink(comm: Community) async {
        guard let currentUser else { return }
        let newCommList = currentUser.commInfoList + [.init(id: comm.id, buddyList: [], alert: true)]
        do {
            try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: newCommList)
        } catch {
            print(#function + "커뮤니티 딥링크로 가입 시 유저의 commInfoList 업데이트 실패")
            self.currentUser?.commInfoList = newCommList
        }
    }
    
    @MainActor
    func leaveComm(commID: String) async {
        guard let currentUser else { return }
        let changedList = currentUser.commInfoList.filter { $0.id != commID }
        do {
            try await firebaseManager.update(data: currentUser, value: \.commInfoList, to: changedList)
            self.currentUser?.commInfoList = changedList
        } catch {
            print(#function + "User의 commInfoList에서 탈퇴할 커뮤니티정보 삭제 실패")
        }
    }
    
    @MainActor
    func commAlertToggle(id: String) async {
        guard var currentUser else { return }
        guard var currentCommInfo = currentUser.commInfoList
            .filter({ $0.id == id })
            .first else { return }
        currentCommInfo.alert.toggle()
        guard let index = currentUser.commInfoList
            .firstIndex(where: { $0.id == currentCommInfo.id }) else { return }
        currentUser.commInfoList[index] = currentCommInfo
        do {
            try await firebaseManager.create(data: currentUser)
            self.currentUser = currentUser
        } catch {
            print(#function + "User Collection에 알람 업데이트 실패")
        }
    }
    
    /// 이메일 회원가입 ->  카카오가입할때
    @MainActor
    func createUser(email: String,
                    passwrod: String,
                    name: String,
                    gender: Gender,
                    description: String,
                    imageURL: String?
    ) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: passwrod)
            self.userSession = result.user
            let user = User(id: result.user.uid,
                            name: name,
                            gender: gender,
                            imageURL: imageURL,
                            description: description,
                            kakaoToken: "카카오토큰",
                            coin: 0,
                            megaphone: 0,
                            showInitial: 0,
                            requestComm: []
            )
            await uploadUserData(user: user)
            print("🔵 회원가입 성공")
        } catch {
            print("🔴 회원가입 실패. 에러메세지: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 이메일 회원가입 정보 등록하기
    @MainActor
    func uploadUserData(user: User) async {
        self.currentUser = user
        print("🦕유저: \(user)")
        do {
            try await firebaseManager.create(data: user)
        } catch {
            print("🦕creatUser에러: \(error.localizedDescription)")
        }
    }
    
    /// 유저 데이터 가져오기
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        print("🦕Auth.currentUser: \(String(describing: userSession))")
        guard let currentUid = userSession?.uid else {
            SignStatusObserved.shared.isNeedLogin = true
            print("🦕로그인된 유저 없음")
            return
        }
        print("🦕UID = \(currentUid)")
        self.currentUser = try? await fetchUser(withUid: currentUid)
        if let currentUser {
            print("🦕현재 로그인된 유저: \(String(describing: currentUser))")
        } else {
            print("🦕현재 로그인된 유저 없음")
        }
    }
    
    /// 코인 사용 업데이트 함수
    func updateUserCoin(to: Int) async {
        guard let currentUser else { return }
        var coin = currentUser.coin
        coin += to
        try? await firebaseManager.update(data: currentUser,
                                          value: \.coin,
                                          to: coin)
        try? await loadUserData()
    }
    
    /// 초성확인권 사용 업데이트 함수
    func updateUserInitialCheck(to: Int) async {
        guard let currentUser else { return }
        var initialCheck = currentUser.showInitial
        initialCheck += to
        try? await firebaseManager.update(data: currentUser,
                                          value: \.showInitial,
                                          to: initialCheck)
        try? await loadUserData()
    }
    
    /// 메가폰 사용 업데이트 함수
    func updateUserMegaphone(to: Int) async {
        guard let currentUser else { return }
        var megaphone = currentUser.megaphone
        megaphone += to
        try? await firebaseManager.update(data: currentUser,
                                          value: \.megaphone,
                                          to: megaphone)
        try? await loadUserData()
    }
    
    func updateUserFCMToken(_ fcmToken: String) async {
        guard let currentUser else { return }
        guard !fcmToken.isEmpty else { return }
        
        try? await firebaseManager.update(data: currentUser,
                                          value: \.fcmToken,
                                          to: fcmToken)
        try? await loadUserData()
    }
    
    // MARK: 제노 뷰
    /// 유저가 문제를 다 풀었을 경우, 다 푼 시간을 서버에 등록함
    @MainActor
    func updateZenoTimer() async {
        do {
            guard let currentUser = currentUser else { return }
            let zenoStartTime = Date().timeIntervalSince1970
            try await firebaseManager.update(data: currentUser, value: \.zenoEndAt, to: zenoStartTime + Double(coolTime))
            try await loadUserData()
        } catch {
            debugPrint(#function + "Error updating zeno timer: \(error)")
        }
    }
    
    // MARK: 제노 뷰
    /// 친구 id 배열로  친구 User  배열 받아오는 함수
    func IDArrayToUserArrary(idArray: [String]) async -> [User] {
        var resultArray: [User] = []
        do {
            for index in 0..<idArray.count {
                let result = try await fetchUser(withUid: idArray[index])
                resultArray.append(result)
            }
        } catch {
            debugPrint(#function + "fetch 유저 실패")
            return []
        }
        return resultArray
    }
    
    // MARK: 제노 뷰
    /// 친구 id로  친구 이름 받아오는 함수
    func IDToName(id: String) async -> String {
        do {
            let result = try await fetchUser(withUid: id)
            return result.name
        } catch {
            debugPrint(#function + "fetch 유저 실패")
        }
        return "fetch실패" }
    
    // MARK: 제노 뷰
    /// 해당 커뮤니티의 친구 수가 4명 이상인지 확인하는 함수
    func hasFourFriends(comm: Community) -> Bool {
        if let currentUser {
            if let buddyListCount = currentUser.commInfoList.first(where: { $0.id == comm.id })?.buddyList.count {
                return buddyListCount >= 4
            }
        } else {
            debugPrint(#function + "실패")
        }
        return false
    }

    // MARK: 제노 뷰
    /// 커뮤니티 id로 친구 id배열을 받아오는 함수.
    func getFriendsInComm(comm: Community) -> [String] {
        if let currentUser {
            return currentUser.commInfoList.first(where: { $0.id == comm.id })?.buddyList ?? []
        } else {
            debugPrint(#function + "commid로 해당하는 community를 찾을 수 없음")
        }
        debugPrint(#function + "currentUser가 없음")
        return []
    }
    
    @MainActor
    func joinNewGroup(newComm: Community?) async {
        guard var currentUser,
              let newComm
        else { return }
        currentUser.commInfoList.append(.init(id: newComm.id, buddyList: [], alert: true))
        do {
            try await firebaseManager.create(data: currentUser)
            self.currentUser = currentUser
        } catch {
            debugPrint(#function + "그룹 생성 변경사항 User Collection에 추가 실패")
        }
    }
    
    /// 파베유저정보 Fetch
    func fetchUser(withUid uid: String) async throws -> User {
        let result = await firebaseManager.read(type: User.self, id: uid)
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }

    /// [가입신청] 보낸 그룹 등록
    @MainActor
    func addRequestComm(comm: Community) async throws {
        guard let currentUser else { return }
		let requestComm = currentUser.requestComm + [comm.id]
        try await firebaseManager.update(data: currentUser.self,
                                         value: \.requestComm,
                                         to: requestComm)
        self.currentUser?.requestComm = requestComm
    }
	
	/// [가입수락] 매니저가 가입을 수락하면 가입한 유저의 그룹 가입요청 데이터가 지워지는 함수
	@MainActor
	func removeRequestComm(comm: Community, user: User) async throws {
		// 1. 파이어베이스에서 현재 유저 requestComm 지우기
		let requestComm = user.requestComm.filter { $0 != comm.id }
		do {
			try await firebaseManager.update(data: user.self,
											 value: \.requestComm,
											 to: requestComm)
		} catch {
			print("🔴 [가입수락] 가입요청 데이터 지우기 실패")
		}
	}
}
