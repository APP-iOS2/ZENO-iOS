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
    @State var isNudgingOn: Bool = false
    @State private var counter: Int = 1
    let zenoDummy = Zeno.ZenoQuestions
    var user = User.dummy
    let hangul = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 30) {
            Image("test_meotsa_logo")
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text("\(user[0].name)님을")
                Text("\(zenoDummy[0].question)")
                Text("으로 선택한 사람")
            }
            Text("\(ChosungRandom(ChosungCheck(word: user[6].name)))")
                .bold()
                .frame(width: 160, height: 80)
                .background(
                    // 색깔 지정되면 변경할 곳.
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 180, height: 90)
                )
            Button {
                isNudgingOn = true
            } label: {
                Text("찌르기")
                    .frame(width: 120, height: 30)
            }
            .initialButtonBackgroundModifier(fontColor: .black, color: .hex("6E5ABD"))
            .alert("\(ChosungRandom(ChosungCheck(word: user[6].name)))님 찌르기 성공", isPresented: $isNudgingOn) {
                Button {
                    isNudgingOn.toggle()
                } label: {
                    Text("확인")
                }
            }
        }
        .padding()
    }
    
    func ChosungCheck(word: String) -> String {
        var result = ""
        // 문자열하나씩 짤라서 확인
        for char in word {
            let octal = char.unicodeScalars[char.unicodeScalars.startIndex].value
            if 44032...55203 ~= octal { // 유니코드가 한글값 일때만 분리작업
                let index = (octal - 0xac00) / 28 / 21
                result += hangul[Int(index)]
            }
        }
        return result
    }
    
    func ChosungRandom(_ word: String) -> String {
        // 문자열을 Character 배열로 변환
        var nameArray = Array(word)
        
        // 하나의 문자를 제외하고 나머지를 "X"로 바꿈
        if nameArray.count > 1 {
            let randomIndex = Int.random(in: 0..<nameArray.count)
            for i in 0..<nameArray.count where i != randomIndex {
                nameArray[i] = "X"
            }
        }
        // 문자 배열을 다시 문자열로 합쳐서 반환
        let result = String(nameArray)
        return result
    }
}

struct AlarmInitialView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmInitialView()
    }
}
