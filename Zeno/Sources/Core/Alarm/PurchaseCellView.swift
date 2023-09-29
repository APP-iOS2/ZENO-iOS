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
    let imageString: String
    let itemQuantity: Int
    let itemTitle: String
    let itemDescription: String
    let itemPrice: Double
    var itemPriceDotTwo: String {
        let priceDotTwo = String(format: "%.2f", itemPrice)
        return priceDotTwo
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "\(imageString)")
                    .frame(width: .screenWidth * 0.04)
                Text("x\(itemQuantity)")
                    .font(.caption2)
                    .padding(EdgeInsets(top: 0, leading: -7, bottom: -10, trailing: 0))
                VStack(alignment: .leading) {
                    Text("\(itemTitle)")
                        .font(.system(size: 27))
                        .padding(.bottom, 8)
                    Text("\(itemDescription)")
                }
            }
            Button {
                // TODO: 나중에 IAP 로 연결 
            } label: {
                Text("$\(itemPriceDotTwo) 결제하기")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.mainColor)
                    .frame(width: .screenWidth * 0.6, height: .screenHeight * 0.04)
            )
        }
        .padding()
        .frame(width: .screenWidth)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(uiColor: backgroundColor))
        )
    }
}

struct PurchaseCellView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseCellView(imageString: "magnifyingglass", itemQuantity: 10, itemTitle: "초성 확인권", itemDescription: "당신을 제노한 사람의 초성 한글자를 보여줄 것임\n*뭐 \n*또 무슨 기능", itemPrice: 1.99)
    }
}
