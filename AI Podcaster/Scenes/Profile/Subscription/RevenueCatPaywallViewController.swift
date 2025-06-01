import UIKit
import RevenueCat
import RevenueCatUI

final class RevenueCatPaywallViewController: UIViewController {
    
    // PaywallViewController'ı tutacak container
    private var containerView: UIView!
    private var paywallVC: PaywallViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Kullanıcı premium ise paywall göstermeye gerek yok
        if IAPService.shared.isPremiumUser() {
            dismiss(animated: true) {
                self.showAlert(title: "Premium Kullanıcı", message: "Zaten premium özelliklere erişiminiz var.")
            }
            return
        }
        
        // Arka planı ayarla
        view.backgroundColor = .systemBackground
        
        // Kapatma butonu ekle
        setupCloseButton()
        
        // Container view ekle
        setupContainerView()
        
        // Offerings'leri yükle
        loadOfferings()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60), // Kapatma butonuna yer bırak
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func loadOfferings() {
        // RevenueCat'in offerings'lerini yükle
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let error = error {
                print("RevenueCat offerings hatası: \(error.localizedDescription)")
                self.showAlert(title: "Hata", message: "Ürünler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.")
                self.dismiss(animated: true)
                return
            }
            
            guard let currentOffering = offerings?.current else {
                print("RevenueCat current offering bulunamadı")
                self.showAlert(title: "Hata", message: "Ürün bilgileri bulunamadı. Lütfen daha sonra tekrar deneyin.")
                self.dismiss(animated: true)
                return
            }
            
            // PaywallViewController'ı göster
            DispatchQueue.main.async {
                self.presentPaywall(with: currentOffering)
            }
        }
    }
    
    private func presentPaywall(with offering: Offering) {
        // PaywallViewController oluştur
        let paywallVC = PaywallViewController(offering: offering)
        self.paywallVC = paywallVC
        
        // Delegate ayarla
        paywallVC.delegate = self
        
        // PaywallViewController'ı child olarak ekle
        addChild(paywallVC)
        paywallVC.view.frame = containerView.bounds
        paywallVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(paywallVC.view)
        paywallVC.didMove(toParent: self)
    }
    
    // Kullanıcıya bilgi mesajı göstermek için yardımcı metod
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PaywallViewControllerDelegate
extension RevenueCatPaywallViewController: PaywallViewControllerDelegate {
    func paywallViewController(_ controller: PaywallViewController, didFinishPurchasingWith customerInfo: CustomerInfo) {
        print("Satın alma tamamlandı: \(customerInfo)")
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        dismiss(animated: true)
    }
    
    func paywallViewController(_ controller: PaywallViewController, didRestorePurchasesWith customerInfo: CustomerInfo) {
        print("Satın alma geri yüklendi: \(customerInfo)")
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
        dismiss(animated: true)
        showAlert(title: "Başarılı", message: "Satın alımlarınız başarıyla geri yüklendi.")
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFailWith error: Error) {
        print("Satın alma başarısız: \(error.localizedDescription)")
        dismiss(animated: true)
        showAlert(title: "Hata", message: "Satın alma işlemi başarısız oldu: \(error.localizedDescription)")
    }
    
    func paywallViewControllerDidCancel(_ controller: PaywallViewController) {
        print("Satın alma iptal edildi")
        dismiss(animated: true)
    }
} 