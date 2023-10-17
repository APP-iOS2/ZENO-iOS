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

final class MypageViewModel: ObservableObject, LoginStatusDelegate {
    func login() async -> Bool {
        return false
    }
    
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
    /// zenoString에 따른 이미지를 받을 데이터
    @Published var zenoStringImage: [String] = []
    /// 비율 항목 계산을 위한 일반 변수
    var itemFrequency = [String: Int]()
    // 각 항목의 비율 계산
    var itemRatios = [String: Double]()
        
    /// zenoString들의 뱃지를 위한 비율을 계산하는 함수 (항목 / 전체 zenoString 개수)
    func zenoStringCalculator() {
        print("😡 \(self.zenoStringAll)")
        print("😡 \(self.zenoStringAll.count)")
        self.itemRatios = [:]
        self.itemFrequency = [:]
        
        // 각 항목의 빈도수 계산
        for item in zenoStringAll {
            if let count = itemFrequency[item] {
                itemFrequency[item] = count + 1
            } else {
                itemFrequency[item] = 1
            }
        }

        for (item, count) in itemFrequency {
            let ratio = Double(count) / Double(zenoStringAll.count)
//            let changePercent = ratio * 100
            self.itemRatios[item] = ratio * 100
        }
        
        // 결과 출력
        for (item, ratio) in itemRatios {
            let percentage = ratio * 100
            print("💰💰 \(item): \(percentage)%")
            print("🦁 \(self.itemRatios)")
        }
    }
    
    /// zenoString == zeno.question으로 사진 찾는 함수
    func findZenoImage(forQuestion question: String, in zenoQuestions: [Zeno]) -> String? {
        for zeno in zenoQuestions where zeno.question == question {
            return zeno.zenoImage
        }
        return nil
    }
//
//    /// zenoString 사진 배열
//    func zenoImageArray() {
//        print("zenoStringAll \(self.zenoStringAll)")
//        for zeno in self.zenoStringAll {
//            if let zenoImage = findZenoImage(forQuestion: zeno, in: Zeno.ZenoQuestions) {
//                self.zenoStringImage.append(zenoImage)
//            }
//        }
//    }

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
    @MainActor
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
                    if let data {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        self.groupList = user.commInfoList
                        self.groupIDList = self.groupList?.compactMap { $0.id }
                        self.friendIDList = self.groupList?.flatMap { $0.buddyList }
                        return true
                    } else {
                        return false
                    }
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
    @MainActor
    func returnFriendInfo(selectedGroupID: String) {
        for friend in self.returnBuddyList(selectedGroupID: selectedGroupID) {
            db.collection("User").document(friend).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    do {
                        if let data {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            self.friendInfo.append(user)
                            print("💙[friendInfo] \(self.friendInfo)")
                        }
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
    @MainActor
    func getCommunityInfo() async {
        guard let groupIDList = self.groupIDList else { return }
        self.commArray = []
        for group in groupIDList {
            do {
                let document = try await db.collection("Community").document(group).getDocument()
                if document.exists {
                    let data = document.data()
                    do {
                        if let data {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let user = try JSONDecoder().decode(Community.self, from: jsonData)
                            self.commArray.append(user)
//                            print("💙[commArray] \(self.commArray)")
                        }
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

    /// 로그아웃
    @MainActor
    func logout() async {
        try? Auth.auth().signOut()
        await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
    }
    
    /// 회원탈퇴
    @MainActor
    func memberRemove() async {
        do {
            if let userInfo {
                print(#function, "✔️\(userInfo)")
                // 파베인증삭제 -> user컬렉션 문서 삭제 -> 로그아웃with 카카오토큰삭제 -> 유저디폴트 삭제 ->
                try await Auth.auth().currentUser?.delete()
                print("✔️회원탈퇴 성공. 1회차")
                try? await firebaseManager.delete(data: userInfo)
                print("✔️User데이터Delete 성공.")
                await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
                print("✔️카카오 토큰 삭제")
            }
        } catch let error as NSError {
            print("✔️로그아웃 오류: \(error.localizedDescription)")
            
            if AuthErrorCode.Code(rawValue: error.code) == .requiresRecentLogin {
                let result = await KakaoAuthService.shared.fetchUserInfo()
                switch result {
                case .success(let (user, _)):
                    if let user {
                        let credential = EmailAuthProvider.credential(withEmail: user.kakaoAccount?.email ?? "",
                                                                      password: String(describing: user.id))
                        do {
                            if let userInfo {
                                try await Auth.auth().currentUser?.reauthenticate(with: credential) // 재인증
                                try? await Auth.auth().currentUser?.delete()
                                print("✔️회원탈퇴 성공. 2회차")
                                try? await firebaseManager.delete(data: userInfo)
                                print("✔️User데이터Delete 성공. 2회차")
                                await KakaoAuthService.shared.logoutUserKakao() // 카카오 로그아웃 (토큰삭제)
                                print("✔️카카오 토큰 삭제 2회차")
                            }
                        } catch {
                            print("✔️재인증실패 : \(error.localizedDescription)")
                        }
                    }
                case .failure(let err):
                    print("✔️카카오유저값 못가져옴 :\(err.localizedDescription)")
                }
            }
        }
    }
    
    /// 회원탈퇴시
    private func removeUserData() {
        // 0. Community컬렉션에서 managerID가 탈퇴한 User인것을 찾고 회원탈퇴하려면 manager위임하고 오라고 하는 부분 필요!!! 임의로 위임해주면 위임받은 사람한테 알림도 가야되고 이것저것 로직이 너무 복잡해짐.
        
        
        // 1. Alarm컬렉션 showUserID가 탈퇴한 User인것의 문서자체를 제거
        // 2. Community컬렉션 joinMembers배열의 id값이 삭제 userid인것을 찾아서 배열 value 제거
        // 3. User컬렉션 buddyList배열의 userid를 찾아서 배열value 제거
        
         
    }
    
}
