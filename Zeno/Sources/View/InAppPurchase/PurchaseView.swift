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
            Rectangle()
                .fill(
                    AngularGradient(gradient: Gradient(colors: [Color.purple, Color.mint]),
                                    center: .topLeading,
                                    angle: .degrees(180 + 55)))
                .frame(width: .screenWidth, height: .screenHeight * 0.2)
                .edgesIgnoringSafeArea(.top)
                .overlay {
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("See who likes you!")
                            .bold()
                            .font(.extraBold(17))
                            .padding(10)
                        Text("View the members")
                        Text("that want to connect with you")
                        Spacer()
                    }
                    .font(.thin(10))
                    .foregroundColor(.white)
                }
            
            Spacer()
            
            PurchaseCellView(itemQuantity: 10,
                             itemTitle: "초성 확인권",
                             itemDescription: "코인 없이 빠르게 초성을 확인할 수 있어요!",
                             itemFeature1: "10회 초성 확인권",
                             itemPrice: "1.99",
                             purchaseAction: {
                Task {
                    if let product = iAPVM.products.last ?? iAPVM.products.first {
                        do {
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
                    } else {
                        print("Products not available")
                    }
                }
            })
            
            Spacer()
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
