//
//  PurchaseView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/27.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject var iAPVM: IAPStore
    @EnvironmentObject var userVM: UserViewModel
    
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
                    ForEach(iAPVM.products) { product in
                        PurchaseCellView(
                            itemQuantity: product.id == "initialCheck" ? 10 : 1,
                            itemTitle: product.id == "initialCheck" ? "초성 확인권" : "메가폰",
                            itemDescription: product.id == "initialCheck" ? "당신을 제노한 사람의 초성이 궁금할 땐?" : "내 마음을 들어내고 싶을 땐?\t\t\t  ",
                            itemFeature1: product.id == "initialCheck" ? "🔎 초성 확인\tex) XㅈX" : "📢 문구,, \nex) 누구누구야! 우리 어디서 만나자 !",
                            itemFeature2: product.id == "initialCheck" ? "🤏🏻 찌르기" : "",
                            itemPrice: product.displayPrice
                        ) {
                            Task {
                                do {
                                    let purchaseResult = try await iAPVM.purchase(product)
                                    if await purchaseResult?.finish() != nil {
                                        await userVM.updateUserInitialCheck(to: 10)
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        } updateUserPurchaseInfo: {
                            // 
                        }
                    }
                }
                .padding(.top, 65)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

//struct PurchaseView_Previews: PreviewProvider {
//    static var previews: some View {
//        PurchaseView()
//            .environmentObject(IAPStore())
//            .environmentObject(AlarmViewModel())
//            .environmentObject(UserViewModel())
//    }
//}
