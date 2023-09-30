//
//  StartButton.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct StartButton: View {
    var body: some View {
        ZStack {
            Text("START")
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                .foregroundColor(.black)
            Rectangle()
                .frame(width: .screenWidth * 0.6, height: .screenHeight * 0.05)
                .cornerRadius(10)
                .foregroundColor(.mainColor)
                .opacity(0.5)
        }
    }
}

struct StartButton_Previews: PreviewProvider {
    static var previews: some View {
        StartButton()
    }
}
