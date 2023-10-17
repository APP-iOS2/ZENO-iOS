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

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(
                        AngularGradient(gradient: Gradient(colors: [Color.purple, Color.mint]),
                                        center: .topLeading,
                                        angle: .degrees(180 + 55)))
                    .frame(width: .screenWidth, height: .screenHeight * 0.4)
                    .offset(y: -350)
                VStack(alignment: .center, spacing: 0) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("See who likes you!")
                        .bold()
                        .font(.title)
                        .padding(10)
                    Text("View the members")
                    Text("that want to connect with you")
                }
                .font(.thin(15))
                .foregroundColor(.white)
                .offset(y: -280)
                PurchaseCellView(itemQuantity: 10,
                                 itemTitle: "초성 확인권",
                                 itemDescription: "코인 없이 빠르게 초성을 확인할 수 있어요!",
                                 itemFeature1: "10회 초성 확인권",
                                 itemPrice: "1.99",
                                 purchaseAction: {
                    Task {
                        do {
                            let product = iAPVM.products[0]
                            let purchaseResult = try await iAPVM.purchase(product)
                            
                            if await purchaseResult?.finish() != nil {
                                switch purchaseResult?.productID {
                                case "initialCheck":
                                    await userVM.updateUserInitialCheck(to: 10)
                                    dismiss()
                                case "megaphone":
                                    await userVM.updateUserMegaphone(to: 1)
                                    dismiss()
                                default:
                                    break
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                })
            }
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
            .environmentObject(IAPStore())
            .environmentObject(UserViewModel())
    }
}
