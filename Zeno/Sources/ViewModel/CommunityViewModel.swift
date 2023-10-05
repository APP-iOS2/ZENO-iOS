//
//  HomeViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/10/04.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

class CommunityViewModel: ObservableObject {
    private let firebaseManager = FirebaseManager.shared
    
    @AppStorage("selectedCommunity") var selectedCommunity: Int = 0
    @Published var allCommunities: [Community] = []
    @Published var joinedCommunities: [Community] = []
    private var allCurrentUsers: [User] = []
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
            return joinedCommunities
        } else {
            return allCommunities.filter { $0.communityName.contains(communitySearchTerm) }
        }
    }
    
    init() {
        Task {
            await fetchAllCommunity()
        }
    }
    
    func filterAllCommunity(keys: [String]) {
        let communities = allCommunities.filter { keys.contains($0.id) }
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
            let currentUserIDs = joinedCommunities[selectedCommunity].joinMembers.map { $0.id }
            let results = await firebaseManager.readDocumentsWithIDs(type: User.self, ids: currentUserIDs)
            let currentUsers = results.compactMap {
                switch $0 {
                case .success(let success):
                    return success
                case .failure:
                    return nil
                }
            }
            self.allCurrentUsers = currentUsers
            filterNormalUser()
            filterRecentlyUser()
        }
    }
    
    func filterNormalUser() {
        let filterID = joinedCommunities[selectedCommunity].joinMembers.filter {
            $0.joinedAt - Date().timeIntervalSince1970 >= -86400 * 3
        }.map { $0.id }
        self.normalUsers = allCurrentUsers.filter { filterID.contains($0.id) }
    }
    
    func filterRecentlyUser() {
        let filterID = joinedCommunities[selectedCommunity].joinMembers.filter {
            $0.joinedAt - Date().timeIntervalSince1970 < -86400 * 3
        }.map { $0.id }
        self.recentlyJoinedUsers = allCurrentUsers.filter { filterID.contains($0.id) }
    }
}
