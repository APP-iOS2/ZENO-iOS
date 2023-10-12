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
        NavigationStack {
            VStack {
                ForEach(iAPVM.products, id: \.self) { product in
                    ZStack {
                        // TODO: 임시세요 !!
                        Image(product.id == "initialCheck" ? "removedBG_Zeno" : "caution")
                            .resizable()
                            .frame(width: .screenWidth * 0.2, height: .screenWidth * 0.2)
                            .offset(x: 90, y: -80)
                        
                        PurchaseCellSndView(
                            itemQuantity: product.id == "initialCheck" ? 10 : 1,
                            itemTitle: product.id == "initialCheck" ? "초성 확인권" : "메가폰",
                            itemDescription: product.id == "initialCheck" ? "당신을 제노한 사람의 초성이 궁금할 땐?" : "내 마음을 들어내고 싶을 땐?",
                            itemFeature1: product.id == "initialCheck" ? "🔎 초성 확인\tex) XㅈX" : "📢 문구,, \nex) 누구누구야! 그때 설렛다",
                            itemFeature2: product.id == "initialCheck" ? "🤏🏻 찌르기" : "",
                            itemPrice: product.displayPrice
                        ) {
                            Task {
                                do {
                                    let purchaseResult = try await iAPVM.purchase(product)
                                    
                                    if await purchaseResult?.finish() != nil {
                                        switch purchaseResult?.productID {
                                        case "initialCheck":
                                            await userVM.updateUserInitialCheck(to: 10)
                                            dismiss()
                                        case "megaphone":
                                            // MARK: - 이후 메가폰 카운트 올려주는 함수 호출하면 됨.
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
                        }
                    }
                }
            }
            .padding(.top, 65)
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
