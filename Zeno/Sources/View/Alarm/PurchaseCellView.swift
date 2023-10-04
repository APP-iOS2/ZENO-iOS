//
//  PurchaseCellView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct PurchaseCellView: View {
    let backgroundColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    let itemQuantity: Int
    let itemTitle: String
    let itemDescription: String
    let itemFeature1: String
    let itemFeature2: String
    let itemPrice: Double
    var itemPriceDotTwo: String {
        let priceDotTwo = String(format: "%.2f", itemPrice)
        return priceDotTwo
    }
    
    var body: some View {
        VStack {
            Text("\(itemTitle)")
                .bold()
                .font(.system(size: 27))
                .padding(.bottom, 8)
            HStack {
                VStack(alignment: .leading) {
                    Text("$\(itemPriceDotTwo)")
                        .font(.system(size: 20))
                    Text("/ \(itemQuantity)회")
                        .font(.caption2)
                }
                .bold()
                Spacer(minLength: 2)
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(itemDescription)")
                    Text("\(itemFeature1)")
                    Text("\(itemFeature2)")
                }
                Spacer()
            }
            Button {
                // TODO: 나중에 IAP 로 연결
            } label: {
                Text("결제하기")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: .screenWidth * 0.6, height: .screenHeight * 0.04)
            )
        }
        .padding()
        .frame(width: .screenWidth)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black, lineWidth: 2)
        )
    }
}

struct PurchaseCellView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseCellView(itemQuantity: 10, itemTitle: "초성 확인권", itemDescription: "당신을 제노한 사람의 초성이 궁금하신가요 ?", itemFeature1: "초성 확인", itemFeature2: "찌르기", itemPrice: 1.99)
    }
}
