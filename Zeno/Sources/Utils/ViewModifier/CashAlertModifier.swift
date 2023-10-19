//
//  CashAlertModifier.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CashAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    var imageTitle: String?
    let title: String
    let content: String
    let retainPoint: Int?
    let lackPoint: Int?
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    
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
                    
                    AlarmCoinShortageView(
                        isPresented: self.$isPresented,
                        imageTitle: self.imageTitle,
                        title: self.title,
                        content: self.content,
                        retainPoint: self.retainPoint,
                        lackPoint: self.lackPoint,
                        primaryButtonTitle: self.primaryButtonTitle,
                        primaryAction: self.primaryAction
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
