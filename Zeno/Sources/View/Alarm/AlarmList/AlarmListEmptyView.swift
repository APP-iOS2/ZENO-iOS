//
//  AlarmListEmptyView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/15.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
// MARK: 10.15 추가
struct AlarmListEmptyView: View {
    var body: some View {
        VStack {
            LottieView(lottieFile: "bell")
                .frame(width: .screenWidth * 0.4, height: .screenHeight * 0.3)
            
            Text("아직 알람이 울리지 않았어요")
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 16))
                .offset(y: -50)
        }
    }
}

struct AlarmListEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmListEmptyView()
    }
}
