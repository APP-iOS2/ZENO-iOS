//
//  AlarmFrontView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/11/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmFrontCardView: View {
    @Binding var isFlipped: Bool
    
    var body: some View {
        VStack {
            Image("removedBG_Zeno")
                .resizable()
                .frame(width: .screenWidth * 0.3, height: .screenHeight * 0.15)
            VStack(spacing: 10) {
                Text("초성을 확인하고 싶다면 ?")
                Text("제노를 눌러주세요")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.purple3)
                .contentShape(Rectangle())
                .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.6)
        )
        .offset(y: -40)
        .opacity(isFlipped ? 0 : 1)
    }
}

struct AlarmFrontView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmFrontCardView(isFlipped: .constant(false))
    }
}
