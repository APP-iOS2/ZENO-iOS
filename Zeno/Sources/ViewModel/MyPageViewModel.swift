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

struct DataForAlarm {
    let receiveUserID: String
    let zenoString: String
}

@MainActor
final class MypageViewModel: ObservableObject {
    /// 파베가져오기
    private let firebaseManager = FirebaseManager.shared
    /// 파이어베이스 Auth의 User
    /// private let userSession = Auth.auth().currentUser
    /// 지금 로그인중인 firebase Auth에 해당 하는 유저의 User 객체 정보 가져오기
    @Published var userInfo: User?
    /// User의 joinedCommInfo 정보
    @Published var groupList: [User.joinedCommInfo]?
    /// User의 그룹 id값만 배열로 담은 값
    @Published var groupIDList: [String]?
    /// User의 전체 친구 id값
    @Published var friendIDList: [User.ID]?
    let db = Firestore.firestore()
    /// User의 commInfo 안의 community id에 해당하는 community를 담을 객체
    @Published var commArray: [Community] = []
    /// User의 각 그룹별 buddylist의 친구 객체 정보는 담을 객체
    @Published var allMyPageFriendInfo: [User?] = []
    /// User의 그룹별 buddyList가 담긴 배열
    @Published var groupFirendList: [String] = []
    /// 친구들의 정보를 담을 유저 데이터
    @Published var friendInfo: [User?] = []
    /// 모든 알람 문서 ID값을 담을 데이터
    @Published var zenoStringAll: [String] = []
    /// 모든 알람 문서 가져와서 담을 데이터
    @Published var allAlarmData: [Alarm] = []

    var itemFrequency = [String: Int]()
    // 각 항목의 비율 계산
    var itemRatios = [String: Double]()
    
    func zenoStringCalculator() {
        // 각 항목의 빈도수 계산
        for item in zenoStringAll {
            if let count = itemFrequency[item] {
                itemFrequency[item] = count + 1
            } else {
                itemFrequency[item] = 1
            }
        }

        for (item, count) in itemFrequency {
            let ratio = Double(count) / Double(zenoStringAll.removeDuplicates().count)
//            let changePercent = ratio * 100
            self.itemRatios[item] = ratio * 100
        }
        
        // 결과 출력
        for (item, ratio) in itemRatios {
            let percentage = ratio * 100
            print("💰💰 \(item): \(percentage)%")
            print("💰💰💰💰 \(self.itemRatios)")
        }
    }
    
    @MainActor
    func fetchAllAlarmData() async {
        print("fetchAllAlarmData fetchAllAlarmData fetchAllAlarmData!!!")
        if let currentUser = Auth.auth().currentUser?.uid {
            print("fetchAllAlarmData !!!! \(currentUser)")
            let results = await firebaseManager.readDocumentsWithIDs(type: Alarm.self, whereField: "receiveUserID", ids: [currentUser])
            print("🔺 result : \(results)")
            self.allAlarmData.removeAll()   // 배열 초기화
            
            for result in results {
                switch result {
                case .success(let alarm):
                    self.allAlarmData.append(alarm)
                case .failure(let error):
                    print("🔺\(error.localizedDescription)")
                }
            }
        }
        
        self.zenoStringAll = self.allAlarmData.map { $0.zenoString }
    }
     
    /// User 객체값 가져오기
    func getUserInfo() async {
        self.groupIDList = []
        if let currentUser = Auth.auth().currentUser?.uid {
            do {
                let document = try await db.collection("User").document(currentUser).getDocument()
                if document.exists {
                    let data = document.data()
                    do {
                        if let data = data {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            self.groupList = user.commInfoList
                            self.groupIDList = self.groupList?.compactMap { $0.id }
                            self.userInfo = user
                        }
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("[Error]! getUserInfo 함수 에러 발생")
                }
            } catch {
                print("Firebase document 가져오기 오류: \(error.localizedDescription)")
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
            guard let currentUser = Auth.auth().currentUser?.uid else {
                return false
            }
            let document = try await db.collection("User").document(currentUser).getDocument()
            if document.exists {
                let data = document.data()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    self.groupList = user.commInfoList
                    self.groupIDList = self.groupList?.compactMap { $0.id }
                    self.friendIDList = self.groupList?.flatMap { $0.buddyList }
                    return true
                } catch {
                    print("JSON parsing Error \(error.localizedDescription)")
                    return false
                }
            } else {
                print("[UserFirendIDList] Firebase document 존재 오류")
                return false
            }
        } catch {
            print("Firebase document 가져오기 오류: \(error)")
            return false
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
    
    /// 피커에서 선택한 그룹의 id와 유저가 가지고 있는 commInfo의 id 중 일치하는 그룹을 찾아서 해당 그룹의 buddyList(id)를 반환하는 함수
    func returnBuddyList(selectedGroupID: String) -> [User.ID] {
        return self.groupList?.first(where: { $0.id == selectedGroupID })?.buddyList ?? []
    }
    
    /// "전체" 그룹에 해당하는 전체 친구의 객체를 가져오는 함수
    @MainActor
    func getAllFriends() async {
        print("💭 [getallfriends의 친구 list] \(self.groupFirendList)")
        for friend in self.groupFirendList {
            do {
                let document = try await db.collection("User").document(friend).getDocument()
                if document.exists {
                    print("❤️‍🩹document!!!!!!")
                    let data = document.data()
                    do {
                        if let data = data {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            self.allMyPageFriendInfo.append(user)
                            dump("💙❤️‍🩹 [allFriendInfo] \(self.allMyPageFriendInfo.count)")
                        }
                    } catch {
                        print("💙 json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("💙[getAllFriends] firebase document 존재 오류")
                }
            } catch {
                print("💙 getAllFriends Error!! \(error.localizedDescription)")
            }
        }
    }
    
    /// BuddyList에서 친구 객체 정보 반환 함수
    func returnFriendInfo(selectedGroupID: String) {
        for friend in self.returnBuddyList(selectedGroupID: selectedGroupID) {
            db.collection("User").document(friend).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        self.friendInfo.append(user)
                        print("💙[friendInfo] \(self.friendInfo)")
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("[returnFriendInfo] firebase document 존재 오류")
                }
            }
        }
    }
    
    /// user가 속한 community 객체의 정보 값 가져오는 함수
    func getCommunityInfo() async {
        guard let groupIDList = self.groupIDList else { return }
        self.commArray = []
        for group in groupIDList {
            do {
                let document = try await db.collection("Community").document(group).getDocument()
                if document.exists {
                    let data = document.data()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(Community.self, from: jsonData)
                        self.commArray.append(user)
//                        print("💙[commArray] \(self.commArray)")
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("[getCommunityInfo] firebase document 존재 오류")
                }
            } catch {
                print("getCommunityInfo Error!! \(error.localizedDescription)")
            }
        }
    }
}
