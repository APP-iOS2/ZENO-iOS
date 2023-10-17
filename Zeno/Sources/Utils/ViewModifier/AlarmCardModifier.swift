//
//  AlarmCardModifier.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/17.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CardGradient: ViewModifier {
    @State var rotation: CGFloat = 0.0
    @Binding var itemWidth: CGFloat
    @Binding var itemHeight: CGFloat
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red,.orange,.yellow,.green,.blue,.purple,.pink]), startPoint: .top, endPoint: .bottom))
        .rotationEffect(.degrees(rotation))
        .mask {
            Circle()
                .stroke(lineWidth: 3)
                .frame(width: itemWidth, height: itemHeight)
        }
    }
}

