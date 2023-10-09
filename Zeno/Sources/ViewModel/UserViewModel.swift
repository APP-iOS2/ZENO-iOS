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
    private let firebaseManager = FirebaseManager.shared
    /// ZenoViewSheet닫는용
    @Published var isShowingSheet: Bool = false
    @Published var kakaoStatus: KakaoSignStatus = .none
    private let coolTime: Int = 7
    
    init() {
        Task {
            try await loadUserData()
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
    func login(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await loadUserData()
            self.kakaoStatus = .signIn
            print("🔵 로그인 성공")
        } catch {
            print("🔴 로그인 실패. 에러메세지: \(error.localizedDescription)")
        }
    }
    /// 이메일 회원가입
    @MainActor
    func createUser(email: String, passwrod: String, name: String, gender: String, description: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: passwrod)
            self.userSession = result.user
            let user = User(id: result.user.uid,
                            name: name,
                            gender: gender,
                            description: description,
                            kakaoToken: "카카오토큰",
                            coin: 0,
                            megaphone: 0,
                            showInitial: 0
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
        guard let currentUid = userSession?.uid else { return print("로그인된 유저 없음")}
        print("\(currentUid)")
        self.currentUser = try await fetchUser(withUid: currentUid)
        print("현재 로그인된 유저: \(currentUser ?? User.dummy[0])")
    }
    /// 로그아웃
    func logout() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
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
    
    func fetchUser(withUid uid: String) async throws -> User {
        let result = await firebaseManager.read(type: User.self, id: uid)
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}

extension UserViewModel {
    /// 카카오로그아웃 && Firebase 로그아웃
    func logoutWithKakao() async {
        await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
        self.logout()
    }
    
    /// 카카오 로그인 && Firebase 로그인
    func loginWithKakao() async {
        let (user, isTokened) = await KakaoAuthService.shared.loginUserKakao()
        
        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 없을 경우 신규가입 진행
                print("토큰여부 \(isTokened)")
                if !isTokened {
                    do {
                        try await self.createUser(email: user.kakaoAccount?.email ?? "",
                                                  passwrod: String(describing: user.id),
                                                  name: user.kakaoAccount?.name ?? "none",
                                                  gender: user.kakaoAccount?.gender?.rawValue ?? "none",
                                                  description: user.kakaoAccount?.legalName ?? "")
                    } catch let error as NSError {
                        switch AuthErrorCode.Code(rawValue: error.code) {
                        case .emailAlreadyInUse: // 이메일 이미 가입되어 있음 -> 이메일, 비번을 활용하여 재로그인
                            do {
                                try await self.login(email: user.kakaoAccount?.email ?? "", password: String(describing: user.id))
                            } catch {
                                print("로그인 실패")
                            }
                        case .wrongPassword:     // 비밀번호 오류
                            print("비밀번호 오류\n관리자 문의 바랍니다.")
                        default:
                            break
                        }
                    }
                } else {
                    // 토큰정보가 있을 경우 로그인 진행
                    do {
                        try await self.login(email: user.kakaoAccount?.email ?? "", password: String(describing: user.id))
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            print("ERROR: 카카오톡 유저정보 못가져옴")
        }
    }
}
