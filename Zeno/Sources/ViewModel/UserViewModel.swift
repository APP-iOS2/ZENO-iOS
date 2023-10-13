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

class UserViewModel: ObservableObject {
    /// 파이어베이스 Auth의 User
    @Published var userSession: FirebaseAuth.User?
    /// 현재 로그인된 유저
    @Published var currentUser: User?
    /// 로그인여부(상태)
    @Published var signStatus: SignStatus = .unSign
    
    @Published var isNickNameRegistViewPop: Bool = false   // 회원가입창 열림 여부
    @Published var isNeedLogin: Bool = false
    
    private let firebaseManager = FirebaseManager.shared
    private let coolTime: Int = 7
    
    init() {
        print("🦕userViewModel 초기화")
        Task {
            try? await loadUserData() // currentUser Value 가져오기 서버에서
            if self.currentUser != nil {
                await self.getSignStatus() // currentUser의 값이 nil이 아닐때만 상태값 가져오기.
            } else {
                isNeedLogin = true
            }
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
    
    /// 이메일 로그인
    @MainActor
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try? await loadUserData()
            
            if self.currentUser != nil {
                self.setSignStatus(.signIn)
            }
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
        guard let currentUid = userSession?.uid else { return print("🦕로그인된 유저 없음")}
        print("🦕UID = \(currentUid)")
        self.currentUser = try? await fetchUser(withUid: currentUid)
        if let currentUser {
            print("🦕현재 로그인된 유저: \(String(describing: currentUser))")
        } else {
            print("🦕현재 로그인된 유저 없음")
        }
    }
    
    /// 로그아웃
    @MainActor
    func logout() async {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
        self.setSignStatus(.unSign)
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
    func joinNewGroup(newID: String) async {
        guard var currentUser else { return }
        currentUser.commInfoList.append(.init(id: newID, buddyList: [], alert: true))
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

    /// 회원탈퇴
    func deleteUser() async {
        do {
            if let currentUser {
                // 파베인증삭제 -> user컬렉션 문서 삭제 -> 로그아웃with 카카오토큰삭제 -> 유저디폴트 삭제 ->
                try await Auth.auth().currentUser?.delete()
                print("🦕회원탈퇴 성공. 1회차")
                try? await firebaseManager.delete(data: currentUser)
                print("🦕User데이터Delete 성공.")
                await self.logoutWithKakao()
                print("🦕카카오 토큰 삭제")
                UserDefaults.standard.removeObject(forKey: "nickNameChanged") // 닉네임 변경창 열렸었는지 판단여부 유저디폴트 삭제

            }
        } catch let error as NSError {
            print("🦕로그아웃 오류: \(error.localizedDescription)")
            
            if AuthErrorCode.Code(rawValue: error.code) == .requiresRecentLogin {
                let result = await KakaoAuthService.shared.fetchUserInfo()
                switch result {
                case .success(let (user, _)):
                    if let user {
                        let credential = EmailAuthProvider.credential(withEmail: user.kakaoAccount?.email ?? "",
                                                                      password: String(describing: user.id))
                        do {
                            if let currentUser {
                                try await Auth.auth().currentUser?.reauthenticate(with: credential) // 재인증
                                try? await Auth.auth().currentUser?.delete()
                                print("🦕회원탈퇴 성공. 2회차")
                                try? await firebaseManager.delete(data: currentUser)
                                print("🦕User데이터Delete 성공. 2회차")
                                await self.logoutWithKakao()
                                print("🦕카카오 토큰 삭제 2회차")
                                UserDefaults.standard.removeObject(forKey: "nickNameChanged") // 닉네임 변경창 열렸었는지 판단여부 유저디폴트 삭제
                            }
                        } catch {
                            print("🦕재인증실패 : \(error.localizedDescription)")
                        }
                    }
                case .failure(let err):
                    print("🦕카카오유저값 못가져옴 :\(err.localizedDescription)")
                }
            }
        }
    }
    
    /// 가입신청 보낸 그룹 등록
    @MainActor
    func addRequestComm(comm: Community) async throws {
        guard let currentUser else { return }
		let requestComm = currentUser.requestComm + [comm.id]
        try await firebaseManager.update(data: currentUser.self,
                                         value: \.requestComm,
                                         to: requestComm)
        self.currentUser?.requestComm = requestComm
    }
   
    @MainActor
    private func getSignStatus() {
        self.signStatus = SignStatus.getStatus() // signStatus 값 가져오기. User정보를 받았을때
        print("🦕signStatus = \(self.signStatus.rawValue)")
    }
    
    @MainActor
    private func setSignStatus(_ status: SignStatus) {
        self.signStatus = status
        self.signStatus.saveStatus()
    }
}
