import Foundation
import RevenueCat
import Combine
import FirebaseAuth
import FirebaseFirestore

final class IAPService: NSObject, PurchasesDelegate {
    
    // MARK: - Singleton
    static let shared = IAPService()
    
    // MARK: - Properties
    @Published var customerInfo: CustomerInfo?
    @Published var offerings: Offerings?
    @Published var isYearlyNonRenewingActive: Bool = false
    
    // Product IDs
    private let monthlyProductID = "com.erenalikoca.AI_Podcaster.Monthly"
    private let lifetimeProductID = "subscription_lifetime"
    
    // Premium entitlement identifier
    private let premiumEntitlementID = "Pro"
    
    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private override init() {
        super.init()
    }
    
    // MARK: - Configuration
    func configure() {
        // RevenueCat configuration (Already done in AppDelegate)
        Purchases.shared.delegate = self
        
        // Kullanıcı kimliğini RevenueCat ile eşleştirelim
        setupUserIdentity()
        
        // Fetch initial data
        fetchCustomerInfo()
        fetchOfferings()
    }
    
    // MARK: - PurchasesDelegate Methods
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        checkAndUpdateNonRenewingStatus(customerInfo: customerInfo)
        
        // Premium durumunu Firebase'e kaydet
        updatePremiumStatusInFirebase()
        
        // Notify subscription status changed
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
    }
    
    // MARK: - Public Methods
    func fetchCustomerInfo(completion: ((CustomerInfo?, Error?) -> Void)? = nil) {
        Purchases.shared.getCustomerInfo { [weak self] (info, error) in
            if let error = error {
                print("Error fetching customer info: \(error.localizedDescription)")
                completion?(nil, error)
                return
            }
            
            self?.customerInfo = info
            
            if let info = info {
                self?.checkAndUpdateNonRenewingStatus(customerInfo: info)
                
                // Update Firebase with latest entitlement status
                self?.updatePremiumStatusInFirebase()
                
                // Notify UI of changes
                NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
            }
            
            completion?(info, error)
        }
    }
    
    func fetchOfferings(completion: ((Offerings?, Error?) -> Void)? = nil) {
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
            }
            self?.offerings = offerings
            completion?(offerings, error)
        }
    }
    
    func purchase(package: Package, completion: @escaping (Result<CustomerInfo, Error>) -> Void) {
        Purchases.shared.purchase(package: package) { [weak self] (transaction, customerInfo, error, userCancelled) in
            if let error = error {
                print("Purchase failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if userCancelled {
                let cancelError = NSError(domain: "IAPService.Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Purchase was cancelled by user"])
                completion(.failure(cancelError))
                return
            }
            
            guard let customerInfo = customerInfo else {
                let missingInfoError = NSError(domain: "IAPService.Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing customer info"])
                completion(.failure(missingInfoError))
                return
            }
            
            // Update customer info and check non-renewing status
            self?.customerInfo = customerInfo
            self?.checkAndUpdateNonRenewingStatus(customerInfo: customerInfo)
            
            // Premium durumunu Firebase'e kaydet
            self?.updatePremiumStatusInFirebase()
            
            // Notify subscription status changed
            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
            
            completion(.success(customerInfo))
        }
    }
    
    func restorePurchases(completion: @escaping (Result<CustomerInfo, Error>) -> Void) {
        // Önce mevcut kullanıcı kimliğini kontrol edelim ve eşleştirelim
        setupUserIdentity()
        
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            if let error = error {
                print("Restore failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let customerInfo = customerInfo else {
                let missingInfoError = NSError(domain: "IAPService.Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing customer info"])
                completion(.failure(missingInfoError))
                return
            }
            
            // Update customer info and check non-renewing status
            self?.customerInfo = customerInfo
            self?.checkAndUpdateNonRenewingStatus(customerInfo: customerInfo)
            
            // Premium durumunu Firebase'e kaydet
            self?.updatePremiumStatusInFirebase()
            
            // Notify subscription status changed
            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
            
            completion(.success(customerInfo))
        }
    }
    
    // MARK: - Subscription Status
    func isPremiumUser() -> Bool {
        // PRIMARY CHECK: RevenueCat entitlements (includes promotional grants from dashboard)
        if let entitlement = customerInfo?.entitlements[premiumEntitlementID],
           entitlement.isActive {
            return true
        }
        
        // SECONDARY CHECK: Direct store subscription verification (fallback)
        if let activeSubscriptions = customerInfo?.activeSubscriptions,
           activeSubscriptions.contains(monthlyProductID) {
            return true
        }
        
        // TERTIARY CHECK: Non-renewing lifetime purchases
        return isYearlyNonRenewingActive
    }
    
    func getSubscriptionType() -> AppUser.SubscriptionType {
        // PRIMARY CHECK: RevenueCat entitlements (includes promotional grants)
        if let entitlement = customerInfo?.entitlements[premiumEntitlementID],
           entitlement.isActive {
            
            // Determine subscription type based on product identifier or entitlement properties
            if entitlement.productIdentifier == lifetimeProductID || isYearlyNonRenewingActive {
                return .pro
            } else {
                return .premium
            }
        }
        
        // SECONDARY CHECK: Direct store subscription verification
        if let activeSubscriptions = customerInfo?.activeSubscriptions,
           activeSubscriptions.contains(monthlyProductID) {
            return .premium
        }
        
        // TERTIARY CHECK: Non-renewing lifetime purchases
        if isYearlyNonRenewingActive {
            return .pro
        }
        
        return .free
    }
    

    
    // MARK: - User Identity Management
    
    /// Firebase Auth kullanıcı kimliğini RevenueCat ile eşleştirir
    private func setupUserIdentity() {
        if let user = Auth.auth().currentUser {
            // Kullanıcı kimliğini RevenueCat'e bildir
            Purchases.shared.logIn(user.uid) { [weak self] (customerInfo, created, error) in
                if let error = error {
                    print("RevenueCat login error: \(error.localizedDescription)")
                    return
                }
                
                self?.customerInfo = customerInfo
                if let customerInfo = customerInfo {
                    self?.checkAndUpdateNonRenewingStatus(customerInfo: customerInfo)
                    
                    // Kullanıcı kimliği eşleştirildikten sonra Firebase'i güncelle
                    self?.updatePremiumStatusInFirebase()
                }
            }
        }
    }
    
    // MARK: - Firebase Integration
    
    // Premium durumunu Firebase'e kaydeder
    func updatePremiumStatusInFirebase() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let subscriptionType = getSubscriptionType()
        let isPremium = subscriptionType != .free
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "isPremium": isPremium,
            "subscriptionType": subscriptionType.rawValue,
            "subscriptionUpdatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Failed to update premium status: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func checkAndUpdateNonRenewingStatus(customerInfo: CustomerInfo) {
        // Check if lifetime purchase is active
        self.isYearlyNonRenewingActive = isLifetimePurchaseActive(in: customerInfo)
    }
    
    private func isLifetimePurchaseActive(in customerInfo: CustomerInfo) -> Bool {
        // Check if the lifetime product exists in non-subscriptions
        for transaction in customerInfo.nonSubscriptions {
            if transaction.productIdentifier == lifetimeProductID {
                return true
            }
        }
        return false
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}

// MARK: - RevenueCat Entitlements Best Practices Documentation
/*
 🚀 REVENUECAT ENTITLEMENTS IMPLEMENTATION GUIDE:
 
 Bu implementation RevenueCat'in en iyi practice'lerini takip eder:
 
 1. ✅ PRIMARY CHECK: customerInfo.entitlements[entitlementID]?.isActive
    - RevenueCat panelinden verilen promotional grants'ları da kapsar
    - Store'dan gelen tüm active subscription'ları otomatik olarak entitlement'a çevirir
    - Cross-platform sync destekler
    - Manual grants otomatik olarak algılanır
 
 2. ✅ SECONDARY CHECK: customerInfo.activeSubscriptions.contains(productID)
    - Direct store verification (fallback)
    - Sadece gerçek store subscription'ları gösterir
    - Promotional grants'ları kapsamaz
 
 3. ✅ TERTIARY CHECK: Non-renewing purchases
    - Lifetime purchases gibi özel durumlar için
 
 🎯 Bu yaklaşım sayesinde:
 - ✅ RevenueCat panelinden kullanıcılara premium access verebilirsiniz
 - ✅ Normal store subscription'ları çalışmaya devam eder
 - ✅ Promotional campaigns yönetebilirsiniz
 - ✅ Cross-platform sync otomatik olarak çalışır
 - ✅ Uygulama her açılışında entitlement durumu Firebase'e senkronize edilir
 
 🔧 Test etmek için:
 1. Settings > Debug Entitlements'tan mevcut durumu kontrol edin
 2. RevenueCat panelinden test kullanıcısına grant verin
 3. Uygulama cache'ini temizleyip fresh data alın (debug butonları ile)
 4. Firebase'deki isPremium field'ını kontrol edin
 
 📱 Uygulama akışı:
 - App launch → cache invalidate → customerInfo fetch → Firebase sync
 - Foreground → fresh check → Firebase sync if needed
 - Purchase/Restore → immediate Firebase sync
 */ 
