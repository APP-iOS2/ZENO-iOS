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
    @State private var backAlert: Bool = false
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

                LottieView(lottieFile: "click")
                    .frame(width: .screenWidth * 0.8, height: .screenWidth * 0.8)
                    .offset(x: .screenWidth/3, y: .screenHeight/4)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isFlipped { // 카드가 뒤집어지면서 back 버튼 나타날 수 있게
                    Button {
                        backAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }
        }
        .alert(isPresented: $backAlert) {
            let firstButton = Alert.Button.destructive(Text("취소")) {
                backAlert = false
            }
            let secondButton = Alert.Button.default(Text("돌아가기")) {
                dismiss()
                backAlert = false
            }
            return Alert(title: Text("이 화면을 나가면 다시 들어올 수 없습니다."),
                         message: Text("돌아가시겠습니까 ?"),
                         primaryButton: firstButton, secondaryButton: secondButton)
        }
    }
}

struct AlarmChangingView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmChangingView(selectAlarm: Alarm(sendUserID: "aa",
                                             sendUserName: "함지수",
                                             sendUserFcmToken: "sendToken",
                                             sendUserGender: .female,
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
