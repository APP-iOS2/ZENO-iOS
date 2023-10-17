//
//  PurchaseCellView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/29.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import StoreKit

struct PurchaseCellView: View {
    let itemQuantity: Int
    let itemTitle: String
    let itemDescription: String
    let itemFeature1: String
    let itemFeature2: String
    let itemPrice: String
    
    var purchaseAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("$\(itemPrice)")
                        .font(.extraBold(30))
                        .shadow(radius: 2)
                        .padding(.trailing, 1)
                        .overlay {
                            LottieView(lottieFile: "dollar")
                                .frame(width: .screenWidth * 0.1, height: .screenHeight * 0.1)
                                .offset(x: -.screenWidth * 0.15, y: -.screenWidth * 0.1)
                        }
                    Text("/ \(itemQuantity)회")
                        .font(.regular(10))
                }
                
                Spacer()
                
                Divider()
                    .foregroundColor(.black)
                    .frame(height: .screenHeight * 0.1)
                
                Spacer()

                VStack(alignment: .center) {
                    Text("\(itemDescription)")
                        .font(.regular(10))
                        .padding(.bottom, 1)
                    Text("\(itemFeature1)")
                        .font(.extraBold(24))
                        .offset(y: -2)
                        .shadow(radius: 2)
                    
                    Button {
                        purchaseAction()
                    } label: {
                        Text("결제하기")
                            .font(.bold(14))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.black)
                            .frame(width: .screenWidth * 0.4, height: .screenHeight * 0.04)
                            .shadow(radius: 2)
                    )
                }
                Spacer()
            }
        }
        .foregroundColor(.white)
        .padding()
        .frame(width: .screenWidth, height: .screenHeight * 0.17)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .foregroundColor(.mainColor)
                .shadow(radius: 3)
        )
    }
}

struct PurchaseCellView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseCellView(itemQuantity: 10, itemTitle: "초성 확인권", itemDescription: "코인 없이 빠르게 초성을 확인할 수 있어요!", itemFeature1: "10회 초성 확인권", itemFeature2: "찌르기", itemPrice: "1.99", purchaseAction: { })
    }
}
