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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            LottieView(lottieFile: "bell3")
                .frame(width: .screenWidth * 0.4, height: .screenHeight * 0.3)
    
            Text("아직 알림이 없어요")
                .font(ZenoFontFamily.NanumSquareNeoOTF.regular.swiftUIFont(size: 14))
                .offset(y: -60)
                .foregroundColor(colorScheme == .light ? .gray4 : .white)
        }
    }
}

struct AlarmListEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmListEmptyView()
    }
}
