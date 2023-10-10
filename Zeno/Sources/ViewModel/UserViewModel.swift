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

final class UserViewModel: ObservableObject {
    /// 파이어베이스 Auth의 User
    @Published var userSession: FirebaseAuth.User?
    /// 현재 로그인된 유저
    @Published var currentUser: User?
    /// ZenoViewSheet닫는용
    @Published var isShowingSheet: Bool = false
    /// 로그인여부(상태)
    @Published var signStatus: SignStatus = .none
    
    private let firebaseManager = FirebaseManager.shared
    private let coolTime: Int = 7
    
    init() {
        print("🦕userViewModel 초기화")
        Task {
            try? await loadUserData() // currentUser Value 가져오기 서버에서
            if self.currentUser != nil {
                await self.getSignStatus() // currentUser의 값이 nil이 아닐때만 상태값 가져오기.
            }
        }
    }
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    @MainActor
    func leaveComm(commID: String) async {
        guard var currentUser else { return }
        currentUser.commInfoList = currentUser.commInfoList.filter { $0.id != commID }
        do {
            try await firebaseManager.create(data: currentUser)
            self.currentUser = currentUser
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
    
    /// 이메일 회원가입
    @MainActor
    func createUser(email: String,
                    passwrod: String,
                    name: String,
                    gender: String,
                    description: String,
                    imageURL: String
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
        try? await firebaseManager.create(data: user)
    }
    
    /// 유저 데이터 가져오기
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = userSession?.uid else { return print("🦕로그인된 유저 없음")}
        print("UID = \(currentUid)")
        self.currentUser = try? await fetchUser(withUid: currentUid)
        print("🦕현재 로그인된 유저: \(currentUser)")
    }
    
    /// 로그아웃
    @MainActor
    func logout() async {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
        self.setSignStatus(.none)
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
    
    /// 유저가 문제를 다 풀었을 경우, 다 푼 시간을 서버에 등록함
    @MainActor
    func updateZenoTimer() async {
        do {
            guard let currentUser = currentUser else { return }
            let zenoStartTime = Date().timeIntervalSince1970
            try await firebaseManager.update(data: currentUser, value: \.zenoEndAt, to: zenoStartTime + Double(coolTime))
            try await loadUserData()
            print("------------------------")
            print("\(zenoStartTime)")
            print("\(zenoStartTime + Double(coolTime))")
            print("updateZenoTimer !! ")
        } catch {
            print("Error updating zeno timer: \(error)")
        }
    }
    
    // MARK: 이 함수가 자원 갉아먹고 있음
    /// 사용자한테 몇초 남았다고 초를 보여주는 함수
    func comparingTime() -> Double {
        let currentTime = Date().timeIntervalSince1970
        
        if let currentUser = currentUser,
           let zenoEndAt = currentUser.zenoEndAt {
            return zenoEndAt - currentTime
        } else {
            return 0.0
        }
    }
    
    // MARK: 제노 뷰 모델로 옮길 예정
    /// 친구 id로  친구 이름 받아오는 함수
    func userIDtoName(id: String) async -> String? {
        do {
            let result = try await fetchUser(withUid: id)
            return result.name
        } catch {
            print("fetch유저 실패")
            return nil
        }
    }
    
    // MARK: 제노 뷰 모델로 옮길 예정
    /// 커뮤니티 id로 커뮤니티 이름 받아오는 함수
    func commIDtoName(id: String) async -> String? {
        do {
            let result = try await fetchCommunity(withUid: id)
            return result.name
        } catch {
            print("fetchName 실패")
            return nil
        }
    }
    
    // MARK: 제노 뷰 모델로 옮길 예정
    func fetchCommunity (withUid uid: String) async throws -> Community {
        let result = await firebaseManager.read(type: Community.self, id: uid)
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    @MainActor
    func joinNewGroup(newID: String) async {
        guard var currentUser else { return }
        currentUser.commInfoList.append(.init(id: newID, buddyList: [], alert: true))
        do {
            try await firebaseManager.create(data: currentUser)
            self.currentUser = currentUser
        } catch {
            print(#function + "그룹 생성 변경사항 User Collection에 추가 실패")
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
        // DB User정보 delete, Auth 정보 Delete 부분 추가하기.  // 현재 작동안됨. 23.10.10
        do {
            if let currentUser {
                try await firebaseManager.delete(data: currentUser)
                try await Auth.auth().currentUser?.delete()
            }
        } catch {
            print("🦕로그아웃 오류 : \(error.localizedDescription)")
            return
        }
    }
    
    /// 가입신청 보낸 그룹 등록
    @MainActor
    func addRequestComm(comm: Community) async throws {
        guard var currentUser else { return }
        try await firebaseManager.update(data: currentUser.self,
                                         value: \.requestComm,
                                         to: currentUser.requestComm + [comm.id])
        self.currentUser?.requestComm += [comm.id]
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
