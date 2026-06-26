import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPurchasing: Bool = false
    @Published var isLoadingProducts: Bool = true
    @Published var purchaseError: Error? = nil
    @Published var hasTipped: Bool = false
    
    // Define the product IDs based on the 3 tiers
    let productIds: [String] = [
        "tip.small",
        "tip.medium",
        "tip.large"
    ]
    
    private var updatesTask: Task<Void, Never>? = nil
    
    init() {
        updatesTask = Task.detached {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
            }
        }
        
        Task {
            await fetchProducts()
            isLoadingProducts = false
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            // Sort products by price
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil
        hasTipped = false
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    hasTipped = true
                case .unverified(_, let error):
                    purchaseError = error
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error
        }
        
        isPurchasing = false
    }
}
