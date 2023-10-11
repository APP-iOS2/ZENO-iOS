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
    
    @State private var chosung: String = ""
    let selectAlarm: Alarm
    
    let hangul = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var body: some View {
        ZStack {
            // 앞면 뷰
            AlarmFrontCardView(isFlipped: $isFlipped)
                .scaleEffect(x: isFlipped ? 1.0 : -1.0, y: 1.0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 0.1, z: 0))
                .opacity(isFlipped ? 0 : 1)
            
            // 뒷면 뷰
            AlarmBackCardView(content1: "\(selectAlarm.receiveUserName)님을",
                                content2: "\(selectAlarm.zenoString)으로 선택한 사람",
                                content3: "\(chosung)",
                                isFlipped: $isFlipped) // true
            .opacity(isFlipped ? 1 : 0) // 버튼을 누를 때만 보이도록 함
            
            VStack {
                Spacer()
                
                Button {
                    isNudgingOn = true
                } label: {
                    WideButton(buttonName: "찌르기", isplay: true)
                }
                .opacity(isFlipped ? 1 : 0)
            }
        }
        .onTapGesture {
            withAnimation {
                isFlipped = true
            }
        }
        .alert("\(chosung)님 찌르기 성공", isPresented: $isNudgingOn) {
            Button {
                // TODO: 찌른 알람을 보내는 함수 호출(push noti 어쩌구) / 찌르기 전용 알람 보내기 - AlarmVM
                isNudgingOn.toggle()
                dismiss()
            } label: {
                Text("확인")
            }
        }
        .task {
            chosung = ChosungCheck(word: selectAlarm.sendUserName)
        }
        .toolbar {
            ToolbarItem {
                if userVM.currentUser?.showInitial ?? 0 > 0 {
                    Button {
                        isCheckInitialTwice = true
                    } label: {
                        Text("다시 확인")
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .foregroundStyle(.black)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.mainColor, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .alert(isPresented: $isCheckInitialTwice) {
            let firstButton = Alert.Button.destructive(Text("취소")) {
                isCheckInitialTwice = false
            }
            let secondButton = Alert.Button.default(Text("사용")) {
                Task {
                    await userVM.updateUserInitialCheck(to: -1)
                }
                chosung = ChosungCheck(word: selectAlarm.receiveUserName)
            }
            return Alert(title: Text("초성 확인권을 사용하여 한번 더 확인하시겠습니까?"),
                         message: Text("초성 확인권:\(userVM.currentUser?.showInitial ?? 0)\n결제 후 잔여 확인권: \((userVM.currentUser?.showInitial ?? 0) - 1)"),
                         primaryButton: firstButton, secondaryButton: secondButton)
        }
    }
    
    /// 초성 확인 로직
    private func ChosungCheck(word: String) -> String {
        var initialResult = ""
        // 문자열하나씩 짤라서 확인
        for char in word {
            let octal = char.unicodeScalars[char.unicodeScalars.startIndex].value
            if 44032...55203 ~= octal { // 유니코드가 한글값 일때만 분리작업
                let index = (octal - 0xac00) / 28 / 21
                initialResult += hangul[Int(index)]
            }
        }
        var nameArray = Array(initialResult)
        // 하나의 문자를 제외하고 나머지를 "X"로 바꿈
        if nameArray.count > 1 {
            let randomIndex = Int.random(in: 0..<nameArray.count)
            for i in 0..<nameArray.count where i != randomIndex {
                nameArray[i] = "X"
            }
        }
        // 문자 배열을 다시 문자열로 합쳐서 반환
        let result1 = String(nameArray)
        return result1
    }
}

struct AlarmChangingView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmChangingView(selectAlarm: Alarm(sendUserID: "aa", sendUserName: "강동원참치", sendUserFcmToken: "sendToken", sendUserGender: "여자", receiveUserID: "bb", receiveUserName: "함지수", receiveUserFcmToken: "token", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "자꾸 눈이 마주치는 사람", createdAt: 91842031))
            .environmentObject(AlarmViewModel())
            .environmentObject(UserViewModel())
    }
}
