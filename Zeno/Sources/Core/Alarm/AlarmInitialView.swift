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
            // TODO: 나중엔 초성 보여주는 로직으로 처리할 것.
            Text("XㅈX")
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
            .initialButtonBackgroundModifier(fontColor: .black, color: .purple)
            .alert("XㅈX님 찌르기 성공", isPresented: $isNudgingOn) {
                Button {
                    isNudgingOn.toggle()
                } label: {
                    Text("확인")
                }
            }
        }
        .padding()
    }
}

struct AlarmInitialView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmInitialView()
    }
}
