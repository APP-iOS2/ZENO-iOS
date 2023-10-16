//
//  TimerViewModel.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/06.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

final class TimerViewModel: ObservableObject {
    @Published var timeRemaining: String = ""
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var futureData: Date? // Optional로 선언
    @Published var timesUp = false
    @Published var myZenoTimer: Int = 0
    
    func updateTimeRemaining() {
        if let futureDate = futureData {
            let remaining = Calendar.current.dateComponents([.minute, .second], from: Date(), to: futureDate)
            let minute = remaining.minute ?? 0
            let second = remaining.second ?? 0
            timeRemaining = "\(minute) 분 \(second) 초 남았어요"
            
            if minute == 0 && second <= 0 {
                self.timer.upstream.connect().cancel()
                timesUp = true
            }
        }
    }
    
    deinit {
        self.timer.upstream.connect().cancel()
    }
    
    // MARK: 이 함수가 자원 갉아먹고 있음
    /// 사용자한테 몇초 남았다고 초를 보여주는 함수
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
