//
//  ZenoViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

final class ZenoViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isPlay: PlayStatus
    @Published var path = NavigationPath()
    @Published var myfriends: [User] = []

    private let firebaseManager = FirebaseManager.shared
    private let coolTime: Int = 600
    
    enum PlayStatus {
        case success
        case lessThanFour
        case notSelected
    }
    
    init() {
        self.isPlay = .notSelected
        self.currentUser = nil
    }
    
    /// 유저 가져오기
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = userSession?.uid else {
            return
        }
        do {
            self.currentUser = try await fetchUser(withUid: currentUid)
        } catch {
            debugPrint("Fetch Error in ZenoViewModel")
        }
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
    @MainActor
    func IDArrayToUserArrary(idArray: [String]) async -> [User] {
        var resultArray: [User] = []
        for index in 0..<idArray.count {
            do {
                let result = try await fetchUser(withUid: idArray[index])
                resultArray.append(result)
            } catch {
                print("\(index)")
                debugPrint(#function + "fetch 유저 실패")
            }
        }
        return resultArray
    }
    
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
    
    func resetZenoNavigation() {
        path = .init()
    }
}
