//
//  AlarmBackCardView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/10/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmBackCardView: View {
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let selectAlarm: Alarm
    @Binding var isFlipped: Bool
    
    var body: some View {
        VStack {
            // TODO: - 성별표시
            RoundedRectangle(cornerRadius: 10)
                .stroke(selectAlarm.sendUserGender == "여자" ? Color.hex("EB0FFE") : Color.hex("0F62FE"), lineWidth: 3)
                .overlay(
                    VStack(alignment: .center, spacing: 10) {
                        VStack(spacing: 20) {
                            Text(content1)
                            Text(content2)
                                .multilineTextAlignment(.center)
                                .bold()
                            Text(content3)
                        }
                        .padding(.bottom, 10)
                        
                        Text(content4)
                            .frame(width: 140, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(isFlipped ? Color.primary : Color.clear, lineWidth: 1)
                                    .frame(width: 140, height: 50)
                            )
                            .padding(.top, 30)
                    }
                        .padding(10)
                )
                .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.6)
                .contentShape(Rectangle()) // 터치 영역때문에
                .scaleEffect(x: isFlipped ? 1.0 : -1.0, y: 1.0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 0.1, z: 0))
                .offset(y: -40)
                .padding(10)
        }
    }
}

struct AlarmBackCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmBackCardView(content1: "여기는 이름",
                          content2: "제노말",
                          content3: "글세용",
                          content4: "옝",
                          selectAlarm: Alarm(sendUserID: "aa",
                                             sendUserName: "강동원참치",
                                             sendUserFcmToken: "sendToken",
                                             sendUserGender: "남자",
                                             receiveUserID: "bb",
                                             receiveUserName: "함지수",
                                             receiveUserFcmToken: "token",
                                             communityID: "cc",
                                             showUserID: "1234",
                                             zenoID: "dd",
                                             zenoString: "자꾸 눈이 마주치는 사람",
                                             createdAt: 91842031),
                          isFlipped: .constant(true))
    }
}
