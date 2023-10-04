//
//  ButtonModifier.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct InitialButtonBackgroundModifier: ViewModifier {
    var color: Color
    var fontColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(fontColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
            )
    }
}
