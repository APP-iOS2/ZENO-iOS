//
//  WideButton.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
/// buttonName : 이름, systemImage: 이미지, isplay: 버튼의 작동여부 
struct WideButton: View {
    @State var buttonName: String
    @State var systemImage: String = "play.fill"
    let isplay: Bool
    
    var body: some View {
        HStack {
            Text("\(buttonName)")
                .font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 20))
                .foregroundColor(isplay ? .white : .gray3)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 21))
                        .offset(x: -.screenWidth * 0.3)
                        .foregroundColor(isplay ? .white : .gray3)
                }
        }
        .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
        .background(isplay ? Color.purple2 : .gray2)
        .cornerRadius(15)
        .shadow(radius: 1)
        .padding(.bottom, 20)
    }
}

struct WideButton_Previews: PreviewProvider {
    static var previews: some View {
        WideButton(buttonName: "Start", systemImage: "play.fill", isplay: false)
    }
}


struct WideButton2: View {
    @State var buttonName: String
    @State var systemImage: String = "play.fill"
    let isplay: Bool
    
    var body: some View {
        HStack {
            Text("\(buttonName)")
                .font(ZenoFontFamily.JalnanOTF.regular.swiftUIFont(size: 20))
                .foregroundColor(isplay ? .white : .gray3)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 21))
                        .offset(x: -.screenWidth * 0.3)
                        .foregroundColor(isplay ? .white : .gray3)
                }
        }
        .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
        .background(isplay ? Color.purple2 : .gray2)
        .cornerRadius(15)
        .shadow(radius: 1)
        .padding(.bottom, 20)
    }
}

//struct WideButton2_Previews: PreviewProvider {
//    static var previews: some View {
//        WideButton2(buttonName: "Start", systemImage: "play.fill", isplay: false)
//    }
//}

