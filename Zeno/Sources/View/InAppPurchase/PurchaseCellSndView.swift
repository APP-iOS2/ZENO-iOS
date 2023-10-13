//
//  PurchaseCellSndView.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/12/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct PurchaseCellSndView: View {
    let itemQuantity: Int
    let itemTitle: String
    let itemDescription: String
    let itemFeature1: String
    let itemFeature2: String
    let itemPrice: String
    
    var purchaseAction: () -> Void
    
    var body: some View {
        ZStack {
            Image("")
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(itemTitle)
                            .font(.system(size: 25))
                            .bold()
                            .padding(.top, 10)
                        
                        HStack {
                            Text(itemPrice)
                            Text("/")
                            Text("\(itemQuantity)회")
                        }
                        Spacer()
                        Text(itemDescription)
                        Text(itemFeature1)
                        Text(itemFeature2)
                    }
                    Spacer()
                }
                
                VStack(alignment: .center) {
                    Button {
                        purchaseAction()
                    } label: {
                        Text("결제하기")
                            .foregroundColor(.white)
                            .frame(width: .screenWidth * 0.4, height: .screenWidth * 0.1)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple3)
                            .frame(width: .screenWidth * 0.4, height: .screenWidth * 0.1)
                    )
                }
            }
        }
        .padding()
        .frame(width: .screenWidth, height: .screenHeight * 0.3)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary, lineWidth: 2)
        )
    }
}

struct PurchaseCellSndView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseCellSndView(itemQuantity: 10,
                            itemTitle: "초성 확인권",
                            itemDescription: "당신을 제노한 사람의 초성이 궁금하신가요 ?",
                            itemFeature1: "초성 확인",
                            itemFeature2: "찌르기",
                            itemPrice: "1.99",
                            purchaseAction: { print("결제 버튼 누름") })
    }
}
