//
//  HomeViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    
    @AppStorage("selectedCommunity") var selectedCommunity: Int = 0
    @Published var allCommunities: [Community] = []
    @Published var joinedCommunities: [Community] = []
    @Published var recentlyJoinedUsers: [User] = []
    @Published var normalUsers: [User] = []
    
    @Published var userSearchTerm: String = ""
    var searchedUsers: [User] {
        if userSearchTerm.isEmpty {
            return normalUsers
        } else {
            return normalUsers.filter { $0.name.contains(userSearchTerm) }
        }
    }
    
    @Published var communitySearchTerm: String = ""
    var searchedCommunity: [Community] {
        if communitySearchTerm.isEmpty {
            return allCommunities
        } else {
            return allCommunities.filter { $0.communityName.contains(communitySearchTerm) }
        }
    }
    
    init() {
        Task {
            await fetchAllCommunity()
        }
    }
    
    @MainActor
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
        self.joinedCommunities = communities
    }
    
    @MainActor
    func fetchAllCommunity() async {
        let results = await firebaseManager.readAllCollection(type: Community.self)
        let communities = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.allCommunities = communities
    }
    
    @MainActor
    func fetchAllUser() async {
        if joinedCommunities.count - 1 >= selectedCommunity {
            await fetchNormalUser()
            await fetchRecentlyUser()
        }
    }
    
    func fetchNormalUser() async {
        let normalMemberID = joinedCommunities[selectedCommunity].joinMembers.filter {
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
        let recentlyJoinedMemberID = joinedCommunities[selectedCommunity].joinMembers.filter {
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
