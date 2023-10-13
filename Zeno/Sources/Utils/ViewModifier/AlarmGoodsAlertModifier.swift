//
//  AlarmGoodsBtnModifier.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/13/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmGoodsAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let content1: String
    let content2: String
    
    let primaryButtonTitle1: String
    let primaryAction1: () -> Void
    
    let primaryButtonTitle2: String
    let primaryAction2: () -> Void
    
    let primaryButtonTitle3: String
    let primaryAction3: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            ZStack {
                if isPresented {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .blur(radius: isPresented ? 2 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            self.isPresented = false // 외부 영역 터치 시 내려감
                        }
                    
                    AlarmGoodsBtnView(
                        isPresented: self.$isPresented,
                        content1: self.content1,
                        content2: self.content2,
                        primaryButtonTitle1: self.primaryButtonTitle1,
                        primaryAction1: self.primaryAction1,
                        primaryButtonTitle2: self.primaryButtonTitle2,
                        primaryAction2: self.primaryAction2,
                        primaryButtonTitle3: self.primaryButtonTitle3,
                        primaryAction3: self.primaryAction3
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(
                isPresented
                ? .spring(response: 0.3)
                : .none,
                value: isPresented
            )
        }
    }
}
