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
    
    @State private var isCheckInitialTwice: Bool = false
    @State private var backAlert: Bool = false
    @State private var isFlipped = false
    @State private var chosung: String = ""
    
    let selectAlarm: Alarm
    
    let hangul = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 앞면 뷰
                AlarmFrontCardView(isFlipped: $isFlipped)
                    .scaleEffect(x: isFlipped ? 1.0 : -1.0, y: 1.0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 0.1, z: 0))
                    .opacity(isFlipped ? 0 : 1)
                
                LottieView(lottieFile: "click")
                    .frame(width: .screenWidth * 0.8, height: .screenWidth * 0.9)
                    .offset(x: .screenWidth/3, y: .screenHeight/4)
                    .opacity(isFlipped ? 0 : 1)
                
                // 뒷면 뷰
                AlarmBackCardView(selectAlarm: selectAlarm,
                                  isFlipped: $isFlipped, chosung: $chosung)
                .opacity(isFlipped ? 1 : 0) // 버튼을 누를 때만 보이도록 함
            }
            .onTapGesture {
                withAnimation {
                    HapticManager.instance.impact(style: .rigid)
                    isFlipped = true
                }
            }
        }
        .usingAlert(
            isPresented: $isCheckInitialTwice,
            imageName: "ticket",
            content: "초성 확인권",
            quantity: userVM.currentUser?.showInitial ?? 0,
            usingGoods: 1) {
                isCheckInitialTwice.toggle()
                Task {
                    await userVM.updateUserInitialCheck(to: -1)
                }
                chosung = ChosungCheck(word: selectAlarm.sendUserName)
        }
        .backAlert(isPresented: $backAlert,
                   title: "이 화면을 나가면 다시 돌아올 수 없습니다.",
                   subTitle: "돌아가시겠습니까?",
                   primaryAction1: {
                dismiss()
                backAlert = false
        })
        .task {
            chosung = ChosungCheck(word: selectAlarm.sendUserName)
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
            ToolbarItem(placement: .navigationBarTrailing) {
                if isFlipped {
                    if userVM.currentUser?.showInitial ?? 0 > 0 {
                        Button {
                            isCheckInitialTwice = true
                        } label: {
                            Text("다시 확인")
                                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .foregroundColor(Color.primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.mainColor, lineWidth: 1)
                            )
                        }
                    }
                }
            }
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
        AlarmChangingView(selectAlarm:
                            Alarm(sendUserID: "aa",
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
                                  createdAt: 91842031
                                 )
        )
        .environmentObject(AlarmViewModel())
        .environmentObject(UserViewModel())
    }
}
