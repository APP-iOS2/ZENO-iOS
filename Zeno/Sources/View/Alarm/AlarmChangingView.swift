//
//  AlarmChangingView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/10/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmChangingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var alarmVM: AlarmViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var isNudgingOn: Bool = false
    @State private var isCheckInitialTwice: Bool = false
    @State private var isFlipped = false
    
    let selectAlarm: Alarm
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 앞면 뷰
                AlarmFrontCardView(isFlipped: $isFlipped)
                    .scaleEffect(x: isFlipped ? 1.0 : -1.0, y: 1.0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 0.1, z: 0))
                    .opacity(isFlipped ? 0 : 1)
                
                // 뒷면 뷰
                AlarmBackCardView(selectAlarm: selectAlarm,
                                  isFlipped: $isFlipped)
                .opacity(isFlipped ? 1 : 0) // 버튼을 누를 때만 보이도록 함
            }
            .onTapGesture {
                withAnimation {
                    isFlipped = true
                }
            }
        }
    }
}

struct AlarmChangingView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmChangingView(selectAlarm: Alarm(sendUserID: "aa",
                                             sendUserName: "함지수",
                                             sendUserFcmToken: "sendToken",
                                             sendUserGender: "여자",
                                             receiveUserID: "bb",
                                             receiveUserName: "함지수",
                                             receiveUserFcmToken: "token",
                                             communityID: "cc",
                                             showUserID: "1234",
                                             zenoID: "dd",
                                             zenoString: "에어팟이 없다는 가정 하에, 줄 이어폰 나눠낄 수 있는 사람",
                                             createdAt: 91842031))
            .environmentObject(AlarmViewModel())
            .environmentObject(UserViewModel())
    }
}
