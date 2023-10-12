//
//  MypageViewModel.swift
//  Zeno
//
//  Created by 박서연 on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

final class MypageViewModel: ObservableObject {
    /// 파베가져오기
    private let firebaseManager = FirebaseManager.shared
    @Published var allComm: [Community] = []
    /// 파이어베이스 Auth의 User
    private let userSession = Auth.auth().currentUser
    /// user의 joinedCommInfo 정보
    @Published var groupList: [User.joinedCommInfo]?
    /// user의 그룹 id값만 배열로 담은 값
    @Published var groupIDList: [String]?
    /// user의 전체 친구 id값
    @Published var friendIDList: [User.ID]?
    let db = Firestore.firestore()
    @Published var commArray: [Community] = []
    
    /// 유저의 commInfo의 id값 가져오기 (유저가 속한 그룹의 id값)1
    func userGroupIDList() {
        if let currentUser = userSession?.uid {
            print("❤️‍🩹❤️‍🩹❤️‍🩹❤️‍🩹\(currentUser)")
            db.collection("User").document(currentUser).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        self.groupList = user.commInfoList
                        self.groupIDList = self.groupList?.compactMap { $0.id }
                        print("❤️‍🩹\(self.groupList)")
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("firebase document 존재 오류")
                }
            }
        }
    }
    
    /// 그룹 id를 입력받아 해당 그룹의 buddyList만 뽑아오는 함수
    func getBuddyList(forGroupID groupID: String) -> [String]? {
        // groupID와 일치하는 joinedCommInfo를 찾음
        if let matchedCommInfo = groupList?.first(where: { $0.id == groupID }) {
            return matchedCommInfo.buddyList
        } else {
            // 일치하는 그룹이 없는 경우 nil 반환
            return nil
        }
    }
    
    /// user의 모든 그룹의 모든 친구 id값을 가져올 수 있는 함수
    @MainActor
    func userFriendIDList() async -> Bool {
        do {
            guard let currentUser = userSession?.uid else {
                return false
            }
            let document = try await db.collection("User").document(currentUser).getDocument()
            if document.exists {
                let data = document.data()

                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    self.groupList = user.commInfoList
                    dump("🛜\(self.groupList)")
                    self.groupIDList = self.groupList?.compactMap { $0.id }
                    self.friendIDList = self.groupList?.flatMap { $0.buddyList }
                    dump("🛜🛜\(self.friendIDList)")

                    return true
                } catch {
                    print("JSON parsing Error \(error.localizedDescription)")
                    return false
                }
            } else {
                print("Firebase document 존재 오류")
                return false
            }
        } catch {
            print("Firebase document 가져오기 오류: \(error)")
            return false
        }
    }

     
    
    /// db의 모든 커뮤니티를 받아오는 함수
    @MainActor
    func fetchAllComm() async {
        let results = await firebaseManager.readAllCollection(type: Community.self)
        let communities = results.compactMap {
            switch $0 {
            case .success(let success):
                return success
            case .failure:
                return nil
            }
        }
        self.allComm = communities
//        filterJoinedComm()
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
    
    // MARK: 제노 뷰 모델로 옮길 예정
    /// 친구 id 배열로  친구 이름 배열 받아오는 함수
    func IDArrayToNameArray(idArray: [String]) async -> [String] {
        var resultArray: [String] = []
        do {
            for index in 0..<idArray.count {
                let result = try await fetchUser(withUid: idArray[index])
                resultArray.append(result.name)
            }
        } catch {
            print(#function + "fetch 유저 실패")
            return []
        }
        return resultArray
    }
    
    
}
