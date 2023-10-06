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
}
