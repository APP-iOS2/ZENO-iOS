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
import FirebaseFirestore

final class MypageViewModel: ObservableObject, LoginStatusDelegate {
    // LoginStatusDelegate 프로토콜 메서드. -> 여기선 사용안함.
    func login() async -> Bool {
        return false
    }
  
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
    
    @Published var isCommunityManagerAlert: Bool = false
    @Published var isUserDataDeleteFailAlert: Bool = false
    
    /// 비율 항목 계산을 위한 일반 변수
    private var itemFrequency = [String: Int]()
    // 각 항목의 비율 계산
    var itemRatios = [String: Double]()
    
    /// 파베가져오기
    private let firebaseManager = FirebaseManager.shared
    
    /// FIrebase DB
    private let db = Firestore.firestore()
    
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
        self.groupIDList = [] // 배열 초기화
        if let currentUser = Auth.auth().currentUser?.uid {
            let result = await firebaseManager.read(type: User.self, id: currentUser)
            switch result {
            case .success(let user):
                self.groupList = user.commInfoList
                self.groupIDList = self.groupList?.compactMap { $0.id }
                self.userInfo = user
                self.friendIDList = self.groupList?.flatMap { $0.buddyList }
            case .failure(let error):
                print(#function, "\(error.localizedDescription)")
            }
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
    
    /// 피커에서 선택한 그룹의 id와 유저가 가지고 있는 commInfo의 id 중 일치하는 그룹을 찾아서 해당 그룹의 buddyList(id)를 반환하는 함수
    func returnBuddyList(selectedGroupID: String) -> [User.ID] {
        return self.groupList?.first(where: { $0.id == selectedGroupID })?.buddyList ?? []
    }
    
    /// "전체" 그룹에 해당하는 전체 친구의 객체를 가져오는 함수
    @MainActor
    func getAllFriends() async {
        self.allMyPageFriendInfo = []
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
    func returnFriendInfo(selectedGroupID: String) async {
        self.friendInfo = []
        for friend in self.returnBuddyList(selectedGroupID: selectedGroupID).removeDuplicates() {
            do {
                let document = try await db.collection("User").document(friend).getDocument() // { document, error in
                if document.exists {
                    let data = document.data()
                    do {
                        if let data = data {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            self.friendInfo.append(user)
                        }
                    } catch {
                        print("json parsing Error \(error.localizedDescription)")
                    }
                } else {
                    print("[returnFriendInfo] firebase document 존재 오류")
                }
            } catch {
                print("returnFriendInfo Error!! \(error.localizedDescription)")
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
    func memberRemove() async -> Bool {
        // TODO: -> 만약에 batch로 DB처리를 하게될 경우 인증관련부터 삭제 후 DB데이터처리하기(왜냐면, 오프라인에서도 동작하기때문)
        
        defer {
            print("인증관련 처리 완료")
            // removeUserRelateData() 여기서 처리하면 될듯
        }
        
        let removeResult = await removeUserRelateData()
        
        switch removeResult {
        case .dataDeleteComplete:
            do {
                if let userInfo {
                    print(#function, "✔️\(userInfo)")
                    // 파베인증삭제 -> user컬렉션 문서 삭제 -> 로그아웃with 카카오토큰삭제 -> 유저디폴트 삭제
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
            return true
        case .communityExists:
            // 커뮤니티 alert 열기 (그룹장으로 존재하는 그룹이 존재합니다. 그룹탭에서 처리바랍니다.( 그룹탭가는길 상세히 알려주기 )
            self.isCommunityManagerAlert = true
            return false
        default:
            // 일반 alert 열기 ( 회원탈퇴시 오류가 발생하였습니다. 앱을 종료 후 재시도바랍니다. )
            self.isUserDataDeleteFailAlert = true
            print(#function, "📝✔️\(removeResult.toString())") // 이걸 어디에 저장해둘곳이 없을까..
            return false
        }
    }
    
    // TODO: - batch를 만들어서 batch로 실행 ㅋㅋ -> 원자적으로 수행되며(트랜잭션과 동일), 오프라인상태에서도 실행됨(트랜잭션보다 좋음) ㅋㅎ 회원탈퇴로직에 딱이다 ㄷㄷ
    // 백그라운드 스레드에서 실행시킬것~ DispatchQueue.global().async{ }
    /// 회원탈퇴시
    private func removeUserRelateData() async -> RemoveFailReason {
        let currentUserID = Auth.auth().currentUser?.uid
        // 0. Community컬렉션에서 managerID가 탈퇴한 User인것을 찾고 회원탈퇴하려면 manager위임하고 오라고 하는 부분 필요!!! 임의로 위임해주면 위임받은 사람한테 알림도 가야되고 이것저것 로직이 너무 복잡해짐. 해당기능이 구현되어있는 곳에서 처리후 오는게 좋을듯.
        
        if let currentUserID {
            let resultComms = await firebaseManager.readDocumentsWithIDs(type: Community.self,
                                                                         whereField: "managerID",
                                                                         ids: [currentUserID])
            
            let resultCommDatas: [Community] = resultComms.compactMap { reu in
                switch reu {
                case .success(let community):
                    return community
                case .failure(let error):
                    print(#function, "\(error.localizedDescription)")
                    return nil
                }
            }
            
            // 매니저 위임하고 오셈ㅋ
            if !resultCommDatas.isEmpty { return .communityExists }
            
            // 1. Alarm컬렉션 showUserID가 탈퇴한 User인것의 문서자체를 제거
            let resultAlarms = await firebaseManager.readDocumentsWithIDs(type: Alarm.self,
                                                                          whereField: "showUserID",
                                                                          ids: [currentUserID])
            
            let resultAlarmDatas: [Alarm] = resultAlarms.compactMap { reu in
                switch reu {
                case .success(let alarm):
                    return alarm
                case .failure(let error):
                    print(#function, "\(error.localizedDescription)")
                    return nil
                }
            }
            
            
            // batch delete 1
            var alarmDelCnt: Int = 0
            // 만약에 알람데이터가 100개  50개 지우다가 51개째 지울때 오류나면 다시 시도시키기 -> 이제 이럴필요없을듯 batch사용하면
            for alarm in resultAlarmDatas {
                do {
                    try await firebaseManager.delete(data: alarm)
                } catch {
                    print(#function, "\(error.localizedDescription)")
                    alarmDelCnt += 1
                    break // TODO: - 지금 break해놓은이유는 트랜잭션을 걸것이기 때문에 걸어둠. 만약에 트랜잭션으로 처리 못하면 break 빼기. 23.10.18
                }
            }
            
            // 알람데이터가 못지운게 있으면 return
            if alarmDelCnt > 0 { return .alarmDataExists }
            
            // 2. Community컬렉션 joinMembers배열의 id값이 삭제할userid인것을 찾아서 배열 value 제거
            let commJoinResults = await firebaseManager.readDocumentsArrayWithID(type: Community.self,
                                                                                 whereField: "joinMembers",
                                                                                 id: currentUserID)
            
            let commJoinResultDatas: [Community] = commJoinResults.compactMap { comm in
                switch comm {
                case .success(let comm):
                    return comm
                case .failure(let error):
                    print(#function, "\(error.localizedDescription)")
                    return nil
                }
            }
            
            // batch update 2
            var commDelCnt: Int = 0
            for commJoin in commJoinResultDatas {
                var joins = commJoin.joinMembers
                joins = joins.filter { $0.id != currentUserID }
                do {
                    try await firebaseManager.update(data: commJoin, value: \.joinMembers, to: joins)
                } catch {
                    print(#function, "✔️\(error.localizedDescription)")
                    commDelCnt += 1
                    break
                }
            }
            
            if commDelCnt > 0 { return .commDataExists }
            
            // 3. User컬렉션 buddyList배열의 userid를 찾아서 배열value 제거
            let userInfos = await firebaseManager.readDocumentsArrayWithID(type: User.self, id: currentUserID)
            
            let userInfoDatas: [User] = userInfos.compactMap { info in
                switch info {
                case .success(let user):
                    return user
                case .failure(let error):
                    print(#function, "\(error.localizedDescription)")
                    return nil
                }
            }
            
            var userDelCnt: Int = 0
            // batch update 3
            for userData in userInfoDatas {
                let newCommInfo = userData.commInfoList.compactMap { comm in
                    var chgComm = comm
                    var buddys = chgComm.buddyList
                    buddys = buddys.filter { buddyID in
                        buddyID != currentUserID
                    }
                    
                    chgComm.buddyList = buddys
                    return chgComm
                }
                
                do {
                    try await firebaseManager.update(data: userData, value: \.commInfoList, to: newCommInfo)
                } catch {
                    print(#function, "✔️\(error.localizedDescription)")
                    userDelCnt += 1
                    break
                }
            }
            
            if userDelCnt > 0 { return .userDataDelError }
        }
        
        return .dataDeleteComplete
    }
    
    /// 삭제불가이유
    enum RemoveFailReason {
        case communityExists
        case alarmDataExists
        case commDataExists
        case dataDeleteComplete
        case userDataDelError
        
        func toString() -> String {
            switch self {
            case .communityExists:
                return "커뮤니티의 매니저로 존재함."
            case .alarmDataExists:
                return "알람데이터가 전부다 지워지지않음."
            case .commDataExists:
                return "커뮤니티 업데이트 오류"
            case .dataDeleteComplete:
                return "데이터 삭제완료"
            case .userDataDelError:
                return "유저BuddyList업데이트 오류"
            }
        }
    }
}
