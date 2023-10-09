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
        self.signStatus = SignStatus.getStatus() // signStatus 값 가져오기.
        print("🦕signStatus = \(self.signStatus.rawValue)")
        Task {
            try? await loadUserData()
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
            self.signStatus = .signIn
            self.signStatus.saveStatus()
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
        self.currentUser = try? await fetchUser(withUid: currentUid)
        print("현재 로그인된 유저: \(currentUser ?? User.dummy[0])")
    }
    
    /// 로그아웃
    func logout() async {
        try? Auth.auth().signOut()
        
        // 메서드 자체를 MainActor로 적용할때와 필요한부분에만 MainActor를 적용하는것이 좀 다른거 같다. 확인중.. GCD와 관련이 있을듯싶다.
        // 일단 예상은 -> MainActor래퍼를 적용한다 => 메인스레드에서 동작하게 하기위해 UserViewModel 클래스가 초기화됨과 동시에 미리 queue에 넣어둔다. ( 그래서 호출하지 않아도 실행이 된다. )
        // 이 logout 메서드에 래퍼로 적용하였을 경우 호출하지 않았는데도 실행이 되었다. 그래서 메서드 내부에서 MainActor로 호출하는걸로 변경하니 잘 반영이 되었음.
        await MainActor.run {
            self.userSession = nil
            self.currentUser = nil
            self.signStatus = .signOut
            self.signStatus.saveStatus()
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
    /// 회원탈퇴
    func deleteUser() async {
        await logoutWithKakao()
        // DB User정보 delete, Auth 정보 Delete 부분 추가하기.  // 현재 작동안됨. 23.10.10
        do {
//            print("🦕\(currentUser)")
            try await firebaseManager.delete(data: currentUser ?? .fakeCurrentUser)
        } catch {
            print("🦕로그아웃 오류 : \(error.localizedDescription)")
            return
        }
        
        await MainActor.run {
            self.signStatus = .none
            self.signStatus.saveStatus()
        }
        print("🦕\(self.signStatus.rawValue)")
    }
    
    /// 카카오로 시작하기
    func startWithKakao() async {
        switch self.signStatus {
        case .signIn:
            break
        case .signOut:
            await loginWithKakaoNoRegist()
        case .none:
            await loginWithKakao()
        }
        try? await loadUserData()
    }
    
    /// 카카오로그아웃 && Firebase 로그아웃
    func logoutWithKakao() async {
        await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
        await self.logout()
    }
    
    /// 카카오 로그인 && Firebase 로그인
    private func loginWithKakao() async {
        let (user, isTokened) = await KakaoAuthService.shared.loginUserKakao()
        
        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 없을 경우 신규가입 진행
                print("토큰여부 \(isTokened)")
                if !isTokened {
                    do {
                        // 회원가입 후 바로 로그인.
                        try await self.createUser(email: user.kakaoAccount?.email ?? "",
                                                  passwrod: String(describing: user.id),
                                                  name: user.kakaoAccount?.name ?? "none",
                                                  gender: user.kakaoAccount?.gender?.rawValue ?? "none",
                                                  description: user.kakaoAccount?.legalName ?? "")
                        
                        await self.login(email: user.kakaoAccount?.email ?? "",
                                         password: String(describing: user.id))
                    } catch let error as NSError {
                        switch AuthErrorCode.Code(rawValue: error.code) {
                        case .emailAlreadyInUse: // 이메일 이미 가입되어 있음 -> 이메일, 비번을 활용하여 재로그인
                            await self.login(email: user.kakaoAccount?.email ?? "",
                                             password: String(describing: user.id))
                            
                        case .invalidEmail: // 이메일 형식이 잘못됨.
                            print("\(user.kakaoAccount?.email ?? "") 이메일 형식이 잘못되었습니다.")
                            
                        default:
                            break
                        }
                    }
                } else {
                    // 토큰정보가 있을 경우 로그인 진행
                    await self.login(email: user.kakaoAccount?.email ?? "",
                                     password: String(describing: user.id))
                }
            }
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            print("ERROR: 카카오톡 유저정보 못가져옴")
        }
    }
    
    /// 카카오 로그인 && Firebase 로그인 ( 회원가입 없음 )
    private func loginWithKakaoNoRegist() async {
        let (user, _) = await KakaoAuthService.shared.loginUserKakao()
        
        if let user {
            // 이메일이 있으면 회원가입, 로그인은 진행이 됨.
            if user.kakaoAccount?.email != nil {
                // 토큰정보가 있을 경우 로그인 진행
                await self.login(email: user.kakaoAccount?.email ?? "",
                                 password: String(describing: user.id))
            }
        } else {
            // 유저정보를 못받아오면 애초에 할수있는게 없음.
            print("ERROR: 카카오톡 유저정보 못가져옴")
        }
    }
}
