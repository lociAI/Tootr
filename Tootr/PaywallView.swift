import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @State private var isPurchasing = false
    
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
                
                VStack(spacing: 12) {
                    Text("Unlock All Sounds!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Get full access to all DJ pads, premium sounds, and unlimited loops for just $0.99.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            isPurchasing = true
                            try? await storeManager.purchase()
                            isPurchasing = false
                            if storeManager.isUnlocked {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text("Unlock for $0.99")
                            }
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(30)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                    }
                    .padding(.horizontal, 40)
                    .disabled(isPurchasing)
                    
                    Button("Restore Purchases") {
                        Task {
                            isPurchasing = true
                            await storeManager.restore()
                            isPurchasing = false
                            if storeManager.isUnlocked {
                                dismiss()
                            }
                        }
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
    }
}
