//
//  AlarmViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

final class AlarmViewModel: ObservableObject {
    @Published var alarmArray: [Alarm] = []
    @Published var isFetchComplete: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var lastVisible: DocumentSnapshot?
    @Published var isPagenationLast: Bool = false
    
    @Published var receiveNotification: String = ""
    
    var dummyAlarmArray: [Alarm] = [
        Alarm(sendUserID: "aa", sendUserName: "보내는유저1", sendUserFcmToken: "sendToken", sendUserGender: .female, receiveUserID: "bb", receiveUserName: "받는유저1", receiveUserFcmToken: "token", communityID: "7182280C-E27A-46A9-A0CB-FF8C6556F8D7", showUserID: "1234", zenoID: "dd", zenoString: "놀이공원에서 같이 교복입고 돌아다니면 재밌을 거 같은 사람", createdAt: 91842031),
        Alarm(sendUserID: "aa", sendUserName: "보내는유저2", sendUserFcmToken: "sendToken", sendUserGender: .male, receiveUserID: "bb", receiveUserName: "받는유저2", receiveUserFcmToken: "token", communityID: "7182280C-E27A-46A9-A0CB-FF8C6556F8D7", showUserID: "12342", zenoID: "dd", zenoString: "공포영화 못볼거 같은 사람", createdAt: 91842031)
    ]
    // Init 처음 불러주는게 왜 불편한ㄱㅏ ? -> 객체 생성시 처음 만들어줌 -> 네트워킹 문제라던가 fetch가 안된다면, 생성이 미뤄짐.
    // 그럼 대기 -> 그럼 앱이 죽은 것 처럼 보임.
//    init(userID: String) {
//        Task {
//            await fetchAlarm(showUserID: userID)
//        }
//    }
    
    // CRUD
    // C => 완전 다 생성
    // R => 읽어옴
    // U => update 일부분 수정 덮어씌움 -> 덮어씌울게 잇나 -> 속성 추가 도 가능 - > ? ?
    // D => Delete -> test 용.
    
    /// 제노 게임에서 사람 선택 시 사용, Firebase Alarm Collection 에 데이터 추가, push notification zeno 질문 메세지로 receive 유저에게 보냄
    @MainActor
    func pushAlarm(sendUser: User, receiveUser: User, community: Community, zeno: Zeno) async {
        let alarm = Alarm(sendUserID: sendUser.id, sendUserName: sendUser.name, sendUserFcmToken: sendUser.fcmToken ?? "empty", sendUserGender: sendUser.gender == .female ? Gender.female : Gender.male, receiveUserID: receiveUser.id, receiveUserName: receiveUser.name, receiveUserFcmToken: receiveUser.fcmToken ?? "empty", communityID: community.id, showUserID: receiveUser.id, zenoID: zeno.id, zenoString: zeno.question, createdAt: Date().timeIntervalSince1970)
        
        await createAlarm(alarm: alarm)
        
        if let token = receiveUser.fcmToken, let alert = receiveUser.commInfoList.first(where: { $0.id == community.id })?.alert {
            if alert == true {
                PushNotificationManager.shared.sendPushNotification(toFCMToken: token, title: "Zeno", body: zeno.question)
            }
        }
    }
    // Firebase Alarm collection에 데이터 추가 및 push notification 찌른 알림 다시 보내기 [원래의 receiveUser가 sendUser가 되게 변경되는 것.]
//    @MainActor
//    func pushNudgeAlarm(nudgeAlarm: Alarm) async {
//        // 이 내부에서 send, receive 관련 내용을 변경해주고 이제 그걸 파베에 올려서 push noti 어쩌구 불러서 보내주면  , , ,
//    }
    
    /// 찌르기 기능시 사용, Firebase Alarm Collection 에 데이터 추가, push notification zeno 질문 메세지로 receive 유저에게 보냄
    @MainActor
    func pushNudgeAlarm(nudgeAlarm: Alarm, currentUserGender: Gender) async {
        // 이 내부에서 send, receive 관련 내용을 변경해주고 이제 그걸 파베에 올려서 push noti 어쩌구 불러서 보내주면  , , ,
        let alarm = Alarm(sendUserID: nudgeAlarm.receiveUserID, sendUserName: nudgeAlarm.receiveUserName, sendUserFcmToken: nudgeAlarm.receiveUserFcmToken, sendUserGender: currentUserGender == .female ? Gender.female : Gender.male, receiveUserID: nudgeAlarm.sendUserID, receiveUserName: nudgeAlarm.sendUserName, receiveUserFcmToken: nudgeAlarm.sendUserFcmToken, communityID: nudgeAlarm.communityID, showUserID: nudgeAlarm.sendUserID, zenoID: "nudge", zenoString: nudgeAlarm.zenoString, createdAt: Date().timeIntervalSince1970)
        await createAlarm(alarm: alarm)
        
        PushNotificationManager.shared.sendPushNotification(toFCMToken: alarm.receiveUserFcmToken, title: "Zeno", body: "\(alarm.zenoString)에 답변으로 지목한 친구가 \(alarm.receiveUserName)님을 콕 👉 찔렀어요 ! ")
    }
    
    // 이걸 호출해야 뷰에서 보임 ! -> Zeno 선택할때마다 호출이 되어야하는 함수 !
    /// 테스트용, Firebase Alarm Collection 에 데이터 추가
    private func createAlarm(alarm: Alarm) async {
        do {
            try await FirebaseManager.shared.create(data: alarm)
        } catch {
            print("firebase Alarm collection add error : \(error)")
        }
    }

    // fetch 함수 -> 항상 불러오는 X ->
    // 페이징 ? -> 너무 많아진다면 페이징처리 !
    /// 해당 유저의 모든 알람을 firebase store 에서 가져옴
    @MainActor
    func fetchAlarm(showUserID: String) async {
        // where은 조건임 ! -> 공통적으로 가지고 있는 것을 가지고 필터링. -> nudge와 alarm을 통합해서 필터링을 하는
        let alarmRef = Firestore.firestore().collection("Alarm")
            .whereField("showUserID", isEqualTo: showUserID)
//            .order(by: "createdAt", descending: true)
        do {
            isFetchComplete = false
            
            let querySnapShot = try await alarmRef.getDocuments()
            self.alarmArray.removeAll()
            
            // 하나의 형태를 temp로 받아서 반복문을 통해 전체를 받아옴, removeAll을 통해 전체를 지우고 다시 받아오는 것.
            try querySnapShot.documents.forEach { queryDocumentSnapshot in
                let tempAlarm = try queryDocumentSnapshot.data(as: Alarm.self)
                self.alarmArray.append(tempAlarm)
            }
            alarmArray.sort { $0.createdAt > $1.createdAt }
            
            isFetchComplete = true
        } catch {
            print("== fetchAlarm : \(error)")
        }
    }
    
    /// push notification 왔을 때 1개만 최신 데이터 가져옴
    @MainActor
    func fetchLastestAlarm(showUserID: String, communityID: String? = nil) async {
        var alarmRef = Firestore.firestore().collection("Alarm")
            .whereField("showUserID", isEqualTo: showUserID)
            .whereField("createdAt", isGreaterThan: self.alarmArray.first?.createdAt ?? 0)
            .order(by: "createdAt", descending: true)
            
        if let communityID {
            alarmRef = alarmRef.whereField("communityID", isEqualTo: communityID)
        }
        alarmRef = alarmRef.limit(to: 1)
        do {
            let querySnapShot = try await alarmRef.getDocuments()
            
            try querySnapShot.documents.forEach { queryDocumentSnapshot in
                let tempAlarm = try queryDocumentSnapshot.data(as: Alarm.self)
                self.alarmArray.insert(tempAlarm, at: 0)
            }
        } catch {
            print("== fetchLastestAlarm : \(error)")
        }
    }
    
    /// TabBarView 에서 앱 켜질 때 emptyView 대신 fetch 하는 동안 ProgressView() 보이게 만드는 함수, 한 번만 실행함
    @MainActor
    func fetchAlarmPagenation(showUserID: String) async {
        isFetchComplete = false
        print("📝 alarm 시작", #function)
        defer {
            print("📝 alarm 끗", #function)
            isFetchComplete = true
        }
        // where은 조건임 ! -> 공통적으로 가지고 있는 것을 가지고 필터링. -> nudge와 alarm을 통합해서 필터링을 하는
        let alarmRef = Firestore.firestore().collection("Alarm")
            .whereField("showUserID", isEqualTo: showUserID)
            .order(by: "createdAt", descending: true)
            .limit(to: 7)
        do {
            let querySnapShot = try await alarmRef.getDocuments()
            self.alarmArray.removeAll()
            
            // 하나의 형태를 temp로 받아서 반복문을 통해 전체를 받아옴, removeAll을 통해 전체를 지우고 다시 받아오는 것.
            try querySnapShot.documents.forEach { queryDocumentSnapshot in
                let tempAlarm = try queryDocumentSnapshot.data(as: Alarm.self)
                self.lastVisible = queryDocumentSnapshot
                self.alarmArray.append(tempAlarm)
            }
        } catch {
            print("== fetchAlarmPagenation : \(error)")
        }
    }
    
    /// 홈 탭에서 커뮤니티 선택할 때마다 호출, 페이지네이션으로 가져오기 전 7개 데이터 한 번 가져오는 함수
    @MainActor
    func fetchAlarmPagenation2(showUserID: String, communityID: String? = nil) async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        // where은 조건임 ! -> 공통적으로 가지고 있는 것을 가지고 필터링. -> nudge와 alarm을 통합해서 필터링을 하는
        var alarmRef = Firestore.firestore().collection("Alarm")
            .whereField("showUserID", isEqualTo: showUserID)
            .order(by: "createdAt", descending: true)
            
        if let communityID {
            alarmRef = alarmRef.whereField("communityID", isEqualTo: communityID)
        }
        alarmRef = alarmRef.limit(to: 7)
        do {
            let querySnapShot = try await alarmRef.getDocuments()
            self.alarmArray.removeAll()
            
            // 하나의 형태를 temp로 받아서 반복문을 통해 전체를 받아옴, removeAll을 통해 전체를 지우고 다시 받아오는 것.
            try querySnapShot.documents.forEach { queryDocumentSnapshot in
                let tempAlarm = try queryDocumentSnapshot.data(as: Alarm.self)
                self.lastVisible = queryDocumentSnapshot
                self.alarmArray.append(tempAlarm)
            }
        } catch {
            print("== fetchAlarmPagenation2 : \(error)")
            isFetchComplete = true
        }
    }
    
    /// 무한 스크롤 시 알람 추가 데이터 가져오는 함수
    @MainActor
    func loadMoreData(showUserID: String) async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        guard let lastVisible = lastVisible else {
            isPagenationLast = true
            return // No more data to load
        }
        
        let db = Firestore.firestore()
        let query = db.collection("Alarm")
            .whereField("showUserID", isEqualTo: showUserID)
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastVisible)
            .limit(to: 10)
        
        do {
            let querySnapShot = try await query.getDocuments()
            
            alarmArray += try querySnapShot.documents.compactMap { queryDocumentSnapshot in
                let tempAlarm = try queryDocumentSnapshot.data(as: Alarm.self)
                self.lastVisible = queryDocumentSnapshot
                return tempAlarm
            }
        } catch {
            print("AlarmLoadMoreData : \(error)")
        }
    }
    
    /// 그룹에서 나가는 경우, 해당 그룹 알람 중 로그인된 유저에게 보여주던 알람 firestore 에서 제거
    @MainActor
    func deleteAlarmWhenLeavingCommunity(communityID: String?, loginUserID: String?) async {
        guard let userID = loginUserID, let communityID else {
            print("deleteAlarm When [ LeavingCommunity ] : loginUserID or communityID is nil")
            return
        }
        
        let deleteUserAlarm = alarmArray.filter { $0.showUserID == userID && $0.communityID == communityID }
        do {
            for alarm in deleteUserAlarm {
                try await FirebaseManager.shared.delete(data: alarm)
            }
            alarmArray.removeAll { $0.showUserID == userID && $0.communityID == communityID }
        } catch {
            print("deleteAlarm When [ LeavingCommunity ] : \(error)")
        }
    }
    
    /// 회원 탈퇴 시 해당 회원에게 보여주던 알람 정보 firestore 에서 삭제
    func deleteAlarmWhenDeleteUser(userID: String?) async {
        guard let userID = userID else {
            print("deleteAlarm When [ DeleteUser ] : userID is nil")
            return
        }
        
        let deleteUserAlarm = alarmArray.filter { $0.showUserID == userID }
        do {
            for alarm in deleteUserAlarm {
                try await FirebaseManager.shared.delete(data: alarm)
            }
        } catch {
            print("deleteAlarm When [ DeleteUser ] : \(error)")
        }
    }
}
