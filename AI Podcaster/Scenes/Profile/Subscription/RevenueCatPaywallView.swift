import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var currentOffering: Offering?
    
    private let premiumEntitlementID = "premium" // Ensure this matches your RevenueCat entitlement ID
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                // Loading state
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            } else if let errorMsg = errorMessage {
                // Error state
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Hata")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(errorMsg)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Tamam")
                            .fontWeight(.semibold)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else if let offering = currentOffering {
                // Paywall content - Wrap in another ZStack for custom close button
                ZStack(alignment: .topTrailing) {
                    PaywallView(offering: offering)
                        .onPurchaseCompleted { customerInfo in
                            // Handle successful purchase
                            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
                            presentationMode.wrappedValue.dismiss()
                            
                            // Show success alert using UIKit since SwiftUI alerts in sheets can be problematic
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first?.rootViewController {
                                    let alert = UIAlertController(
                                        title: "Başarılı",
                                        message: "Premium aboneliğiniz aktif edildi! Tüm premium özellikleri kullanabilirsiniz.",
                                        preferredStyle: .alert
                                    )
                                    alert.addAction(UIAlertAction(title: "Harika!", style: .default))
                                    rootVC.present(alert, animated: true)
                                }
                            }
                        }
                        .onRestoreCompleted { customerInfo in
                            // Handle restore
                            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
                            let hasPremium = customerInfo.entitlements[premiumEntitlementID]?.isActive == true
                            
                            if hasPremium {
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                            // Show appropriate message
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first?.rootViewController {
                                    let title = hasPremium ? "Başarılı" : "Bilgi"
                                    let message = hasPremium 
                                        ? "Satın alımlarınız başarıyla geri yüklendi." 
                                        : "Hesabınızda aktif bir abonelik bulunamadı."
                                    
                                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                                    rootVC.present(alert, animated: true)
                                }
                            }
                        }
                        .onPurchaseFailure { error in
                            // Handle purchase failure
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first?.rootViewController {
                                    let alert = UIAlertController(
                                        title: "Hata",
                                        message: "Satın alma işlemi başarısız oldu: \(error.localizedDescription)",
                                        preferredStyle: .alert
                                    )
                                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                                    rootVC.present(alert, animated: true)
                                }
                            }
                        }
                    
                    // Custom close button that will always be on top and responsive
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 36, height: 36)
                                .shadow(radius: 2)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                    .zIndex(100) // Ensure it's on top of everything
                }
            }
        }
        .onAppear {
            // Check if user is already premium
            if IAPService.shared.isPremiumUser() {
                errorMessage = "Zaten premium özelliklere erişiminiz var."
                isLoading = false
                return
            }
            
            loadOfferings()
        }
    }
    
    private func loadOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("RevenueCat offerings error: \(error.localizedDescription)")
                    errorMessage = "Ürünler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin."
                    return
                }
                
                guard let currentOffering = offerings?.current else {
                    print("RevenueCat current offering not found")
                    errorMessage = "Ürün bilgileri bulunamadı. Lütfen daha sonra tekrar deneyin."
                    return
                }
                
                self.currentOffering = currentOffering
            }
        }
    }
}

// MARK: - SwiftUI Preview
struct RevenueCatPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        RevenueCatPaywallView()
    }
}

// MARK: - UIKit Integration Helper
extension RevenueCatPaywallView {
    // Method to present the SwiftUI view from UIKit
    static func present(from viewController: UIViewController) {
        let hostingController = UIHostingController(rootView: RevenueCatPaywallView())
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: true)
    }
} 