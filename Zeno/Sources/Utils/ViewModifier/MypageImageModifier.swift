//
//  MypageImageModifier.swift
//  Zeno
//
//  Created by woojin Shin on 2023/10/24.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct MypageImageModifier: ViewModifier {
    func body(content: Content) -> some View {
          content
            .scaledToFit()
            .clipShape(Circle())
            .scaledToFill()
            .frame(width: 120, height: 120)
            .aspectRatio(contentMode: .fit)
            .overlay {
                Circle().stroke(Color(uiColor: .systemGray3), lineWidth: 1)
            }
    }
}

extension View {
    func imageCustomSizing() -> some View {
        self.modifier(MypageImageModifier())
    }
}

struct MypageImageModifier_Previews: PreviewProvider {
    static var previews: some View {
        Image(systemName: "plus")
            .imageCustomSizing()
    }
}
