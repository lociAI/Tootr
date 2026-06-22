import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var unlockProduct: Product?
    
    let productID = "com.jtechsoftware.tootr.unlock"
    
    private var updatesTask: Task<Void, Never>? = nil
    
    init() {
        updatesTask = Task {
            for await result in Transaction.updates {
                if let transaction = try? result.payloadValue {
                    await handle(transaction)
                }
            }
        }
        
        Task {
            await fetchProducts()
            await checkEntitlements()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            if let product = products.first {
                self.unlockProduct = product
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue {
                if transaction.productID == productID {
                    self.isUnlocked = true
                }
            }
        }
    }
    
    func purchase() async throws {
        guard let product = unlockProduct else { return }
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            if let transaction = try? verificationResult.payloadValue {
                await handle(transaction)
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func restore() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }
    
    private func handle(_ transaction: Transaction) async {
        if transaction.productID == productID {
            self.isUnlocked = true
        }
        await transaction.finish()
    }
}
