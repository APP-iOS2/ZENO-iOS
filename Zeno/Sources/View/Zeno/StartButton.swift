//
//  StartButton.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct StartButton: View {
    let isplay: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
                .cornerRadius(26)
                .foregroundColor(isplay ? .purple2 : .gray)
                .opacity(0.5)
                .shadow(radius: 3)
            Image(systemName: "play.fill")
                .font(.system(size: 21))
                .offset(x: -.screenWidth * 0.3)
                .foregroundColor(isplay ? .white : .gray)
            Text("START")
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                .foregroundColor(isplay ? .white : .gray)
        }
    }
}

struct StartButton_Previews: PreviewProvider {
    static var previews: some View {
        StartButton(isplay: true)
    }
}
