//
//  ZenoViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class ZenoViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    private let coolTime: Int = 15
    
    enum PlayStatus {
        case success
        case lessThanFour
        case notSelected
    }
    
    @Published var isPlay: PlayStatus
    
    init() {
        self.isPlay = .notSelected
    }
    
    /// isPlay 배출
    func isPlayStatus(comm: Community, currentUser: User) {
        if hasFourFriends(comm: comm, currentUser: currentUser) {
            isPlay = .success
        } else {
            isPlay = .lessThanFour
        }
    }
    
    // MARK: 제노 뷰
    /// 커뮤니티 id로 친구 id배열을 받아오는 함수.
    func getFriendsInComm(comm: Community, currentUser: User?) -> [String] {
        if let currentUser {
            return currentUser.commInfoList.first(where: { $0.id == comm.id })?.buddyList ?? []
        } else {
            debugPrint(#function + "commid로 해당하는 community를 찾을 수 없음")
        }
        debugPrint(#function + "currentUser가 없음")
        return []
    }
    
    // MARK: 제노 뷰
    /// 해당 커뮤니티의 친구 수가 4명 이상인지 확인하는 함수
    func hasFourFriends(comm: Community, currentUser: User?) -> Bool {
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
    /// 유저가 문제를 다 풀었을 경우, 다 푼 시간을 서버에 등록함
    @MainActor
    func updateZenoTimer(currentUser: User?) async {
        do {
            guard let currentUser = currentUser else { return }
            let zenoStartTime = Date().timeIntervalSince1970
            try await firebaseManager.update(data: currentUser, value: \.zenoEndAt, to: zenoStartTime + Double(coolTime))
            // try await loadUserData()
        } catch {
            debugPrint(#function + "Error updating zeno timer: \(error)")
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
