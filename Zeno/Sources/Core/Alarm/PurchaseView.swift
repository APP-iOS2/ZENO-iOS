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
            VStack {
                PurchaseCellView(imageString: "magnifyingglass", itemQuantity: 10, itemTitle: "초성 확인권", itemDescription: "당신을 제노한 사람의 초성 한글자를 보여줄 것임\n* 뭐 \n* 또 무슨 기능", itemPrice: 1.99)
                
                PurchaseCellView(imageString: "megaphone", itemQuantity: 1, itemTitle: "메가폰", itemDescription: "하고 싶은 이야기를 해보시죵 ? 문구 몰,루", itemPrice: 0.99)
            }
            .bold()
            .navigationTitle("Purchase")
            .padding(.bottom, .screenHeight * 0.2)
            .background(
                LinearGradient(colors: [.cyan, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: .screenWidth, height: .screenHeight * 0.26)
                    .offset(y: -(.screenHeight * 0.44) )
            )
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
    }
}
