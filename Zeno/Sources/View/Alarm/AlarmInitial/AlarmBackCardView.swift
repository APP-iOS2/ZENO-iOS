//
//  AlarmBackCardView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/10/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmBackCardView: View {
    @EnvironmentObject var alarmVM: AlarmViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    let selectAlarm: Alarm
    
    @Binding var isFlipped: Bool
    @Binding var chosung: String

    @State private var isNudgingOn: Bool = false
    @State private var isNoneUser: Bool = false
    @State private var counter: Int = 0
    @State private var isDisabledNudge: Bool = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(AngularGradient(gradient: Gradient(colors: [.mainColor, Color.ggullungColor]), center: .topLeading, angle: .degrees(180 + 20)))
                .shadow(radius: 3, x: 5, y: 5)
                .overlay(
                    VStack(alignment: .center, spacing: 20) {
                        Spacer()
                        
                        Image("removedBG_Zeno")
                            .resizable()
                            .frame(width: .screenWidth * 0.3, height: .screenWidth * 0.3)
                            .padding(.bottom, 20)
                            .confettiCannon(counter: $counter, num: 50, confettis: [.text("😈"), .text("💜")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: .screenWidth * 0.7)
                        
                        VStack(spacing: 3) {
                            Text("\(selectAlarm.receiveUserName)님을")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
                            Text(selectAlarm.zenoString)
                                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 25))
                                .multilineTextAlignment(.center)
                                .shadow(radius: 2)
                            Text("으로 선택한 사람은 ?")
                                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 17))
                        }
                        .foregroundColor(.white)
                        
                        // 초성은 조금 더 크게 보여줘야 하지 않을까 ?
                        Text(chosung)
                            .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                            .foregroundColor(.black)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundColor(.white)
                                    .shadow(radius: 3)
                                    .frame(width: .screenWidth * 0.3, height: .screenHeight * 0.04)
                            )
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        Button {
                            isNudgingOn = true
                            counter += 1
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: .screenWidth * 0.5, height: .screenHeight * 0.05)
                                    .foregroundColor(isDisabledNudge ? .gray2 : .white)
                                    .shadow(radius: 1)
                                Text("찌르기")
                                    .foregroundColor(isDisabledNudge ? .white: .ggullungColor)
                                    .font(.extraBold(15))
                            }
                        }
                        .disabled(isDisabledNudge)
                        .padding(.bottom, 20)
                        .alert("찌르기가 허용되지 않는 유저입니다. ", isPresented: $isNoneUser) {
                            Button {
                                isNoneUser = false
                            } label: {
                                Text("확인")
                            }
                        }
                    }
                    .padding(10)
                )
                .frame(width: .screenWidth * 0.85, height: .screenHeight * 0.63)
                .offset(y: -40)
                .padding(10)
        }
        .scaleEffect(x: isFlipped ? 1.0 : -1.0, y: 1.0)
        .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 0.1, z: 0))
        .cashAlert(isPresented: $isNudgingOn,
                   imageTitle: "point",
                   title: "\(chosung)님을 찌르시겠습니까 ?",
                   content: "\(chosung)님을 찌르시겠습니까 ?",
                   retainPoint: 1,
                   lackPoint: 1,
                   primaryButtonTitle: "확인") {
            Task {
                await alarmVM.pushNudgeAlarm(nudgeAlarm: selectAlarm, currentUserGender: userVM.currentUser?.gender ?? .female)
            }
            isDisabledNudge = true
        }
    }
    
    private func sendNudgeNotification(receiveUserID: String) async {
        let receiveUser = try? await userVM.fetchUser(withUid: receiveUserID)
        if receiveUser != nil {
            await alarmVM.pushNudgeAlarm(nudgeAlarm: selectAlarm, currentUserGender: userVM.currentUser?.gender ?? .female)
        } else {
            // 유저가 없다는 팝업창
            isNoneUser = true
        }
    }
}

struct AlarmBackCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmBackCardView(selectAlarm: Alarm(sendUserID: "aa",
                                             sendUserName: "함지수",
                                             sendUserFcmToken: "sendToken",
                                             sendUserGender: .male,
                                             receiveUserID: "bb",
                                             receiveUserName: "함지수",
                                             receiveUserFcmToken: "token",
                                             communityID: "cc",
                                             showUserID: "1234",
                                             zenoID: "dd",
                                             zenoString: "자꾸 눈이 마주치는 사람",
                                             createdAt: 91842031),
                          isFlipped: .constant(true),
                          chosung: .constant(""))
        .environmentObject(AlarmViewModel())
        .environmentObject(UserViewModel())
    }
}
