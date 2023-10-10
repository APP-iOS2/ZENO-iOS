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

class AlarmViewModel: ObservableObject {
    @Published var alarmArray: [Alarm] = []
    
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
    
    // 이걸 호출해야 뷰에서 보임 ! -> Zeno 선택할때마다 호출이 되어야하는 함수 !
    func createAlarm(alarm: Alarm) async {
        try? await FirebaseManager.shared.create(data: alarm)
    }
    
    // 한개짜리 ? -> 필요한가 ?
    func readAlarm(alarm: Alarm) async {
    }
    
    // fetch 함수 -> 항상 불러오는 X ->
    // 페이징 ? -> 너무 많아진다면 페이징처리 !
    @MainActor
    func fetchAlarm(showUserID: String) async {
        // where은 조건임 ! -> 공통적으로 가지고 있는 것을 가지고 필터링. -> nudge와 alarm을 통합해서 필터링을 하는
        let alarmRef = Firestore.firestore().collection("Alarm")
            .whereField("showUserID", isEqualTo: showUserID)
        do {
            let querySnapShot = try await alarmRef.getDocuments()
            self.alarmArray.removeAll()
            
            // 하나의 형태를 temp로 받아서 반복문을 통해 전체를 받아옴, removeAll을 통해 전체를 지우고 다시 받아오는 것.
            try querySnapShot.documents.forEach { queryDocumentSnapshot in
                let tempAlarm = try queryDocumentSnapshot.data(as: Alarm.self)
                self.alarmArray.append(tempAlarm)
            }
        } catch {
            print(error)
        }
    }
    
    // 필터링용
}
