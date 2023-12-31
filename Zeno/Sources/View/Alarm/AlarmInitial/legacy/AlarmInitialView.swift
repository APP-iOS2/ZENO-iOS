//
//  AlarmInitialView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

/// 초성 확인 뷰
struct AlarmInitialView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var alarmVM: AlarmViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var isNudgingOn: Bool = false
    @State private var isCheckInitialTwice: Bool = false

    @State private var counter: Int = 0
    @State private var chosung: String = ""
    let hangul = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    let selectAlarm: Alarm
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: .screenWidth * 0.7, height: .screenHeight * 0.6)
                    .confettiCannon(counter: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 235)
                    .offset(y: -40)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(selectAlarm.sendUserName)님을")
                        Text("\(selectAlarm.zenoString)")
                            .font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 16))
                        Text("으로 선택한 사람")
                    }
                    .font(ZenoFontFamily.NanumSquareNeoOTF.bold.swiftUIFont(size: 15))
                    .padding(.bottom, 10)
                    
                    Text(chosung)
                        .bold()
                        .frame(width: 160, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                                .frame(width: 180, height: 60)
                        )
                    
                    Spacer()
                    
                    Button {
                        isNudgingOn = true
                    } label: {
                        WideButton(buttonName: "찌르기", systemImage: "", isplay: true)
                    }
                    .alert("\(chosung)님 찌르기 성공", isPresented: $isNudgingOn) {
                        Button {
                            isNudgingOn.toggle()
                            dismiss()
                        } label: {
                            Text("확인")
                        }
                    }
                }
                .padding()
                .task {
                    chosung = ChosungCheck(word: selectAlarm.receiveUserName)
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

struct AlarmInitialView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmInitialView(selectAlarm: Alarm(sendUserID: "aa", sendUserName: "함지수", sendUserFcmToken: "sendToken", sendUserGender: .female, receiveUserID: "bb", receiveUserName: "강동원참치", receiveUserFcmToken: "token", communityID: "cc", showUserID: "1234", zenoID: "dd", zenoString: "자꾸 눈이 마주치는 사람", createdAt: 91842031))
            .environmentObject(AlarmViewModel())
            .environmentObject(UserViewModel())
    }
}
