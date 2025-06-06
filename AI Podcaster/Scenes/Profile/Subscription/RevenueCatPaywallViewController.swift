// AI Podcaster/Scenes/Profile/Subscription/RevenueCatPaywallViewController.swift

import UIKit
import RevenueCat
import RevenueCatUI
import SnapKit
import SafariServices // Safari'yi açmak için import edin

final class RevenueCatPaywallViewController: UIViewController {
    
    // MARK: - Properties
    private var loadingIndicator: UIActivityIndicatorView!
    private var paywallVC: PaywallViewController?
    private let premiumEntitlementID = "premium"
    
    // MARK: - UI Components for Links
    private lazy var linksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var termsOfUseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("termsOfUse", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(openTermsOfUse), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("privacyPolicy", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IAPService.shared.isPremiumUser() {
            dismiss(animated: true) {
                self.showAlert(title: NSLocalizedString("premiumUser", comment: ""), message: NSLocalizedString("alreadyHavePremium", comment: ""))
            }
            return
        }
        
        view.backgroundColor = .systemBackground
        
        setupLoadingIndicator()
        setupLinkButtons() // Yeni fonksiyonu çağırıyoruz
        
        loadingIndicator.startAnimating()
        loadOfferings()
    }
    
    // MARK: - UI Setup
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupLinkButtons() {
        view.addSubview(linksStackView)
        linksStackView.addArrangedSubview(termsOfUseButton)
        linksStackView.addArrangedSubview(privacyPolicyButton)
        
        linksStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.leading.trailing.equalToSuperview().inset(32)
        }
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
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("errorLoadingProducts", comment: ""),
                        completion: { self.dismiss(animated: true) }
                    )
                    return
                }
                
                guard let currentOffering = offerings?.current else {
                    print("RevenueCat current offering not found")
                    self.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("errorProductInfo", comment: ""),
                        completion: { self.dismiss(animated: true) }
                    )
                    return
                }
                
                self.presentPaywall(with: currentOffering)
            }
        }
    }
    
    private func presentPaywall(with offering: Offering) {
        let fontProvider = CustomPaywallFontProvider(fontName: "Helvetica")
        let paywallVC = PaywallViewController(
            offering: offering,
            fonts: fontProvider,
            displayCloseButton: true,
            shouldBlockTouchEvents: false
        )
        
        paywallVC.delegate = self
        
        addChild(paywallVC)
        view.addSubview(paywallVC.view)
        
        paywallVC.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.linksStackView.snp.top).offset(-8) // Paywall'ı linklerin üstüne konumlandır
        }
        paywallVC.didMove(toParent: self)
        
        self.paywallVC = paywallVC
    }
    
    // MARK: - Actions
    @objc private func openTermsOfUse() {
        // BURAYA KENDİ KULLANIM ŞARTLARI URL'NİZİ GİRİN
        guard let url = URL(string: "https://podcasterai.wordpress.com/terms-of-use/") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    @objc private func openPrivacyPolicy() {
        // BURAYA KENDİ GİZLİLİK POLİTİKASI URL'NİZİ GİRİN
        guard let url = URL(string: "https://podcasterai.wordpress.com") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - PaywallViewControllerDelegate
extension RevenueCatPaywallViewController: PaywallViewControllerDelegate {
    func paywallViewController(_ controller: PaywallViewController, didFinishPurchasingWith customerInfo: CustomerInfo) {
        print("Purchase completed: \(customerInfo)")
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        dismiss(animated: true) {
            if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                let successAlert = UIAlertController(
                    title: NSLocalizedString("success", comment: ""),
                    message: NSLocalizedString("premiumActivated", comment: ""),
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: NSLocalizedString("great", comment: ""), style: .default))
                topVC.present(successAlert, animated: true)
            }
        }
    }
    
    func paywallViewController(_ controller: PaywallViewController, didRestorePurchasesWith customerInfo: CustomerInfo) {
        print("Purchases restored: \(customerInfo)")
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        let hasPremium = customerInfo.entitlements[premiumEntitlementID]?.isActive == true
        dismiss(animated: true) {
            if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                let title = hasPremium ? NSLocalizedString("success", comment: "") : NSLocalizedString("info", comment: "")
                let message = hasPremium ? NSLocalizedString("restoreSuccess", comment: "") : NSLocalizedString("noActiveSubscription", comment: "")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                topVC.present(alert, animated: true)
            }
        }
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFailWith error: Error) {
        print("Purchase failed: \(error.localizedDescription)")
        dismiss(animated: true) {
            if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                let alert = UIAlertController(
                    title: NSLocalizedString("error", comment: ""),
                    message: "\(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
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
