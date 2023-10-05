//
//  IAPStore.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/5/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import StoreKit

final class IAPStore: ObservableObject {
    /// App store conncect에서 생성하는 제품을 식별하는 ID 배열, 추후에 메가폰 적용
    private var productIDs = ["initialCheck", "megaphone"]
    @Published var products = [Product]()
    /// 소모성 상품
    @Published var purchasedConsumables = [Product]()
    /// 환불처리를 위한 배열
    @Published var entitlements = [Transaction]()
    
    var transactionListener: Task<Void, Error>?
    
    init() {
        // 놓치는 거래가 없도록 하기 위한
        transactionListener = listenForTransactions()
        
        Task {
            // 일단 init되면서 item 불러오기.
            print(" 시작 - request")
            await requestProducts()
            print(" 완료 ? ? ? ? ? ? - request")
            await updateCurrentEntitlements()
        }
    }
    
    // 앱이 꺼져있을 땐 거래가 되지 않도록.
    deinit {
        transactionListener?.cancel()
    }
    
    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(.verified(let transaction)):
            // product type에 따라 분류해서 카운팅
            switch product.type {
            case .consumable:
                purchasedConsumables.append(product)
//            case .nonConsumable:
//                purchasedNonConsumables.insert(product)
            default:
                return nil
            }
            // 결제 성공
            await transaction.finish()
            return transaction
            
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    /// 구매가 일어난 이후에도 에러가 발생할 수 있음 -> 거래 업데이트를 실시간으로 청취하여 해결 가능
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handle(transactionVerification: result)
            }
        }
    }
    
    /// 거래된 데이터를 가져오기 위해 존재.
    private func updateCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = await self.handle(transactionVerification: result) {
                entitlements.append(transaction)
            }
        }
    }
    
    /// 구매 복원 옵션
    @MainActor
     func restore() async throws {
      try await AppStore.sync()
    }
    
    @MainActor
    @discardableResult
    private func handle(transactionVerification result: VerificationResult<Transaction>) async -> Transaction? {
        switch result {
        case let .verified(transaction):
            guard let product = self.products.first(where: { $0.id == transaction.productID }) else { return transaction }
            guard !transaction.isUpgraded else { return nil }
            try? await self.purchase(product)
            await transaction.finish()
            
            return transaction
        default:
            return nil
        }
    }
}
