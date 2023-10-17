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
    @State private var purchaseAlert: Bool = false
    
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
            .alert(isPresented: $purchaseAlert) {
                let firstButton = Alert.Button.destructive(Text("취소")) {
                    purchaseAlert = false
                }
                let secondButton = Alert.Button.default(Text("돌아가기")) {
                    dismiss()
                    purchaseAlert = false
                }
                return Alert(title: Text("이 화면을 나가시면 다시 들어올 수 없습니다."),
                             message: Text("돌아가시겠습니까 ?"),
                             primaryButton: firstButton, secondaryButton: secondButton)
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
