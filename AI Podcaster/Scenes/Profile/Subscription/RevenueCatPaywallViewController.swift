import UIKit
import RevenueCat
import RevenueCatUI

final class RevenueCatPaywallViewController: UIViewController {
    
    // MARK: - Properties
    private var loadingIndicator: UIActivityIndicatorView!
    private var paywallVC: PaywallViewController?
    private let premiumEntitlementID = "premium" // Ensure this matches your RevenueCat entitlement ID
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if user is already premium
        if IAPService.shared.isPremiumUser() {
            dismiss(animated: true) {
                self.showAlert(title: "Premium Kullanıcı", message: "Zaten premium özelliklere erişiminiz var.")
            }
            return
        }
        
        // Set background
        view.backgroundColor = .systemBackground
        
        // Setup loading indicator
        setupLoadingIndicator()
        
        // Setup close button
        setupCloseButton()
        
        // Load offerings
        loadingIndicator.startAnimating()
        loadOfferings()
    }
    
    // MARK: - UI Setup
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        // Make button more visible and touchable
        closeButton.backgroundColor = .systemGray6
        closeButton.tintColor = .systemGray
        closeButton.layer.cornerRadius = 18
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        closeButton.layer.shadowOpacity = 0.2
        closeButton.layer.shadowRadius = 2
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - RevenueCat Integration
    private func loadOfferings() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                if let error = error {
                    print("RevenueCat offerings error: \(error.localizedDescription)")
                    self.showAlert(
                        title: "Hata", 
                        message: "Ürünler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.",
                        completion: { self.dismiss(animated: true) }
                    )
                    return
                }
                
                guard let currentOffering = offerings?.current else {
                    print("RevenueCat current offering not found")
                    self.showAlert(
                        title: "Hata", 
                        message: "Ürün bilgileri bulunamadı. Lütfen daha sonra tekrar deneyin.",
                        completion: { self.dismiss(animated: true) }
                    )
                    return
                }
                
                self.presentPaywall(with: currentOffering)
            }
        }
    }
    
    private func presentPaywall(with offering: Offering) {
        // Create the paywall view controller with custom fonts (optional)
        let fontProvider = CustomPaywallFontProvider(fontName: "Helvetica")
        let paywallVC = PaywallViewController(
            offering: offering,
            fonts: fontProvider,
            displayCloseButton: true,
            shouldBlockTouchEvents: false
        )
        
        // Set delegate
        paywallVC.delegate = self
        
        // Add the paywall as a child view controller
        addChild(paywallVC)
        paywallVC.view.frame = view.bounds
        paywallVC.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.addSubview(paywallVC.view)
        paywallVC.didMove(toParent: self)
        
        // Save reference
        self.paywallVC = paywallVC
    }
    
    // Helper method to show alerts with optional completion
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - PaywallViewControllerDelegate
extension RevenueCatPaywallViewController: PaywallViewControllerDelegate {
    func paywallViewController(_ controller: PaywallViewController, didFinishPurchasingWith customerInfo: CustomerInfo) {
        print("Purchase completed: \(customerInfo)")
        
        // Post notification to update UI elsewhere in the app
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        
        // Dismiss the paywall
        dismiss(animated: true) {
            // Show success message
            if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                let successAlert = UIAlertController(
                    title: "Başarılı", 
                    message: "Premium aboneliğiniz aktif edildi! Tüm premium özellikleri kullanabilirsiniz.", 
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "Harika!", style: .default))
                topVC.present(successAlert, animated: true)
            }
        }
    }
    
    func paywallViewController(_ controller: PaywallViewController, didRestorePurchasesWith customerInfo: CustomerInfo) {
        print("Purchases restored: \(customerInfo)")
        
        // Post notification to update UI elsewhere in the app
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        
        // Dismiss only if the user has the premium entitlement
        let hasPremium = customerInfo.entitlements[premiumEntitlementID]?.isActive == true
        
        dismiss(animated: true) {
            // Show appropriate message
            if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                let title = hasPremium ? "Başarılı" : "Bilgi"
                let message = hasPremium 
                    ? "Satın alımlarınız başarıyla geri yüklendi." 
                    : "Hesabınızda aktif bir abonelik bulunamadı."
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                topVC.present(alert, animated: true)
            }
        }
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFailWith error: Error) {
        print("Purchase failed: \(error.localizedDescription)")
        
        dismiss(animated: true) {
            // Show error message
            if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                let alert = UIAlertController(
                    title: "Hata", 
                    message: "Satın alma işlemi başarısız oldu: \(error.localizedDescription)", 
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                topVC.present(alert, animated: true)
            }
        }
    }
    
    func paywallViewControllerDidCancel(_ controller: PaywallViewController) {
        print("Purchase cancelled")
        dismiss(animated: true)
    }
}

// MARK: - Helper Extension
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? self
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? self
        }
        
        return self
    }
} 