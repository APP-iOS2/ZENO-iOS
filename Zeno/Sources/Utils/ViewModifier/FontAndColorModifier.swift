//
//  FontAndColorModifier.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/06.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation
import SwiftUI

struct BlueAndBMfont: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(.bold(20))
            .foregroundColor(colorScheme == .light ? .ggullungColor : .gray2)
            .offset(y: -100)
    }
}

extension View {
    func boldAndOffset40() -> some View {
        modifier(BlueAndBMfont())
    }
}
