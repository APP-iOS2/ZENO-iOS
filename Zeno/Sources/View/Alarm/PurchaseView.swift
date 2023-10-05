//
//  PurchaseView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct PurchaseView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(
                        AngularGradient(gradient: Gradient(colors: [Color.purple, Color.mint]),
                                        center: .topLeading,
                                        angle: .degrees(180 + 55)))
                    .frame(width: .screenWidth, height: .screenHeight * 0.4)
                    .offset(y: -350)
                VStack(alignment: .center, spacing: 10) {
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("See who likes you!")
                        .bold()
                        .font(.title)
                    Text("View the members")
                    Text("that want to connect with you")
                }
                .foregroundColor(.white)
                .offset(y: -280)
                
                VStack {
                    PurchaseCellView(itemQuantity: 10, itemTitle: "초성 확인권", itemDescription: "당신을 제노한 사람의 초성이 궁금할 땐?", itemFeature1: "🔎 초성 확인\tex) XㅈX", itemFeature2: "🤏🏻 찌르기", itemPrice: 1.99)
                    PurchaseCellView(itemQuantity: 1, itemTitle: "메가폰", itemDescription: "내 마음을 들어내고 싶을 땐?\t\t\t  ", itemFeature1: "📢 문구,, \nex) 누구누구야! 우리 어디서 만나자 !", itemFeature2: "", itemPrice: 0.99)
                }
                .padding(.top, 65)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
    }
}
