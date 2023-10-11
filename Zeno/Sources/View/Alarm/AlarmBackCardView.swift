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
    @Binding var isFlipped: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.primary, lineWidth: 3)
            .overlay(
                VStack {
                    VStack(spacing: 4) {
                        Text(content1)
                        Text(content2)
                    }
                    .padding(.bottom, 10)
                    
                    Text(content3)
                        .frame(width: 140, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(isFlipped ? Color.primary : Color.clear, lineWidth: 1)
                                .frame(width: 140, height: 50)
                        )
                }
            )
            .frame(width: .screenWidth * 0.75, height: .screenHeight * 0.6)
            .contentShape(Rectangle()) // 터치 영역때문에
            .scaleEffect(x: isFlipped ? 1.0 : -1.0, y: 1.0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 0.1, z: 0))
            .offset(y: -40)
            .padding(10)
    }
}

struct AlarmBackCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmBackCardView(content1: "여기는 이름", content2: "제노말", content3: "글세용", isFlipped: .constant(true))
    }
}
