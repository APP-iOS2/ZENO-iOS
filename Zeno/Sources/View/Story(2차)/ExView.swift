//
//  ExView.swift
//  Zeno
//
//  Created by 유하은 on 2023/10/12.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct ExView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray2)
                .cornerRadius(10)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(20), anchor: .center)
                .shadow(radius: 10, x: 5)
            
            Rectangle()
                .foregroundColor(.black)
                .cornerRadius(10)
                .opacity(0.8)
                .frame(width: 180, height: 150)
                .offset(y: -15)
                .rotationEffect(.degrees(20), anchor: .center)
            
            Image(systemName: "plus.square.on.square")
                .foregroundColor(.gray2)
                .rotationEffect(.degrees(20), anchor: .center)
                .offset(y: -10)
            
            Image("sticker")
                .resizable()
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-10), anchor: .center)
                .shadow(radius: 10, x: 5)
                .offset(x: 120, y: -60)
        }
    }
}

struct ExView_Previews: PreviewProvider {
    static var previews: some View {
        ExView()
    }
}
