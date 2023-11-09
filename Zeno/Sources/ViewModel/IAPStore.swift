//
//  IAPStore.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/5/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import StoreKit

public enum StoreError: Error {
    case failedVerification
}

final class IAPStore: ObservableObject {
    /// App store conncect에서 생성하는 제품을 식별하는 ID 배열, 추후에 메가폰 적용
    private let productIDs = ["initialCheck"]
    
    @Published var products = [Product]()
    /// 소모성 상품
    @Published var __consumableProducts: [Product]
    @Published  var __purchasedIdentifiers = Set<String>()
    
    var transactionListener: Task<Void, Error>?
    
    init() {
        __consumableProducts = []
        
        // 놓치는 거래가 없도록 하기 위한
        transactionListener = listenForTransactions()
        
        Task {
            // 일단 init되면서 item 불러오기.
            print(" 상품 Request ---")
            await requestProducts()
            print(" 상품 Request 완료 ---")
        }
    }
    
    // 앱이 꺼져있을 땐 거래가 되지 않도록.
    deinit {
        transactionListener?.cancel()
    }
    
    @MainActor
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            
            var newNonconsums: [Product] = []
            var newSubscriptions: [Product] = []
            var newConsums: [Product] = []
            
            // 상품의 타입에 맞게 분류
            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newConsums.append(product)
                case .nonConsumable:
                    newNonconsums.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    break
                }
            }
            
            __consumableProducts = newConsums
            print("💩 소모성 : \(__consumableProducts)")
        } catch {
            print("⚠️ 상품 request 실패: \(error)")
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    // 거래가 유효한지 확인
                    let transaction = try self.checkVerified(result)
                    
                    await self.updatePurchasedIdentifiers(transaction)
                    await transaction.finish()
                } catch {
                    print("⚠️ Transaction.updates에서 문제가 있는 것. ")
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // JWS를 파싱했지만 확인은 실패 -> 유저한테 전달 X
            throw StoreError.failedVerification
        case .verified(let safe):
            // isPurchased에서 부른경우 safe는 StoreKit.Transaction
            return safe
        }
    }
    
    @MainActor
    func updatePurchasedIdentifiers(_ trd: Transaction) async {
        // 앱스토어에서 거래 취소가 되지 않았으면 __purchasedIdentifiers 여기에 추가
        if trd.revocationDate == nil {
            __purchasedIdentifiers.insert(trd.productID)
        } else {
            // 앱스토어에서 거래 취소가 되었다면, __purchasedIdentifiers에서 삭제 -> 기한 만료이거나, 정말 취소한 경우 등
            __purchasedIdentifiers.remove(trd.productID)
        }
    }
    
    func AppStoreSync() async {
        try? await AppStore.sync()
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        // Begin a purchase.
        let result = try await product.purchase() // authentication 인증 : 디버그에서는 팝업창
        
        switch result {
        case .success(let verification):
            /// `verification`은 가로 안에서 선언 되었는데, 밖에서 사용이 가능 하다.
            let transaction = try checkVerified(verification)
            // Deliver content to the user.
            await updatePurchasedIdentifiers(transaction)
            
            // Always finish a transaction.
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
}
