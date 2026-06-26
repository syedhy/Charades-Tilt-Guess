import SwiftUI
import StoreKit

struct BuyMeACoffeeView: View {
    @StateObject private var storeKitManager = StoreKitManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            DoodlePaperBackground()
            
            VStack(spacing: 32) {
                // Header
                HStack {
                    DoodleIconButton(
                        symbol: "xmark",
                        accent: AppTheme.Colors.paperBright,
                        size: 48,
                        accessibilityLabel: "Close"
                    ) {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.brown)
                    .padding(32)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.paperBright)
                            .overlay(
                                Circle().stroke(AppTheme.Colors.ink, lineWidth: 4)
                            )
                    )
                
                Text("Buy me a coffee")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.ink)
                
                Text("If you're enjoying the game, consider supporting the development!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                    .padding(.horizontal, 32)
                
                if storeKitManager.hasTipped {
                    Text("Thank you for your support! ❤️")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.green)
                        .padding(.top, 16)
                } else if storeKitManager.isLoadingProducts {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading options...")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.6))
                    }
                    .padding(.top, 32)
                } else if storeKitManager.products.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.orange)
                        Text("Could not load options.")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink)
                        Text("Please check your network, or run this app in the iOS Simulator to load local mock products.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 16) {
                        ForEach(storeKitManager.products) { product in
                            Button(action: {
                                Task {
                                    await storeKitManager.purchase(product)
                                }
                            }) {
                                HStack {
                                    Text(product.displayName)
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(AppTheme.Colors.ink)
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(AppTheme.Colors.ink.opacity(0.7))
                                }
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppTheme.Colors.paperBright)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(AppTheme.Colors.ink, lineWidth: 3)
                                        )
                                )
                                .padding(.horizontal, 32)
                            }
                            .disabled(storeKitManager.isPurchasing)
                        }
                    }
                    .padding(.top, 16)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
