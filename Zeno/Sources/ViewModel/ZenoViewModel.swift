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
    @Published var userSession: FirebaseAuth.User?
    @Published var isShowingSheet: Bool
    
    private let coolTime: Int = 15
    
    init(isShowingSheet: Bool) {
        self.isShowingSheet = isShowingSheet
    }
    
    /// 유저가 문제를 다 풀었을 경우, 다 푼 시간을 서버에 등록함
    func updateZenoTimer(currentUser: User?) async {
         do {
             guard let currentUser = currentUser else { return }
             let zenoStartTime = Date().timeIntervalSince1970
             try await FirebaseManager.shared.update(data: currentUser, value: \.zenoEndAt, to: zenoStartTime + Double(coolTime))
             // try await loadUserData()
             print("------------------------")
             print("\(zenoStartTime)")
             print("\(zenoStartTime + Double(coolTime))")
             print("updateZenoTimer !! ")
         } catch {
             print("Error updating zeno timer: \(error)")
         }
     }
     
     /// 유저가 제노를 시작했는지, 안했는지 여부를 판단함 (서버가 맞을지 유저 디포츠가 맞을진 모르겟음)
     func updateUserStartZeno(to: Bool, currentUser: User?) async {
         do {
             guard let currentUser = currentUser else { return }
             try await FirebaseManager.shared.update(data: currentUser, value: \.startZeno, to: to)
             //try await loadUserData()
             print("updateUserStartZeno ")
         } catch {
             print("Error updateStartZeno : \(error)")
         }
     }

     /// 사용자한테 몇초 남았다고 초를 보여주는 함수
     // MARK: 이 함수가 자원 갉아먹고 있음
     func comparingTime(currentUser: User?) -> Double {
         let currentTime = Date().timeIntervalSince1970
         
         if let currentUser = currentUser,
            let zenoEndAt = currentUser.zenoEndAt {
             return zenoEndAt - currentTime
         } else {
             return 0.0
         }
     }
}
