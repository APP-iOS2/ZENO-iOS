//
//  HomeViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class HomeViewModel: ObservableObject {
    @AppStorage("selectedCommunity") var selectedCommunity: Int = 0
    @Published var communities: [Community] = []
    @Published var recentlyJoinedUsers: [User] = []
    @Published var normalUsers: [User] = []
    private let firebaseManager = FirebaseManager.shared
    
    func fetchCommunity(keys: [String]) async {
        let results = await firebaseManager.readDocumentsWithIDs(type: Community.self, ids: keys)
        let communities = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.communities = communities
    }
    
    func fetchAllUser() async {
        if communities.count - 1 >= selectedCommunity {
            await fetchNormalUser()
            await fetchRecentlyUser()
        }
    }
    
    func fetchNormalUser() async {
        let normalMemberID = communities[selectedCommunity].joinMembers.filter {
            $0.joinedAt - Date().timeIntervalSince1970 >= (-86400 * 3)
        }.map { $0.id }
        let results = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: normalMemberID)
        let normalUsers = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.normalUsers = normalUsers
    }
    
    func fetchRecentlyUser() async {
        let recentlyJoinedMemberID = communities[selectedCommunity].joinMembers.filter {
            $0.joinedAt - Date().timeIntervalSince1970 < (-86400 * 3)
        }.map { $0.id }
        let results = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: recentlyJoinedMemberID)
        let recentlyJoinedUsers = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.recentlyJoinedUsers = recentlyJoinedUsers
    }
}
