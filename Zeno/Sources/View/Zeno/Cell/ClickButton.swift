//
//  ClickButton.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ClickButton: View {
    @State var buttonName: String
    @State var systemImage: String = "play.fill"
    let isplay: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
                .cornerRadius(20)
                .foregroundColor(isplay ? .purple2 : .gray)
                .opacity(0.5)
                .shadow(radius: 3)
            Image(systemName: systemImage)
                .font(.system(size: 21))
                .offset(x: -.screenWidth * 0.3)
                .foregroundColor(isplay ? .white : .gray)
            Text("\(buttonName)")
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                .foregroundColor(isplay ? .white : .gray)
        }
        .offset(y: -20)
    }
}

struct StartButton_Previews: PreviewProvider {
    static var previews: some View {
        ClickButton(buttonName: "START", systemImage: "play.fill", isplay: true)
    }
}
