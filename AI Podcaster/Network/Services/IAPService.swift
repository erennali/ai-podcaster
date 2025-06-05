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
    private let premiumEntitlementID = "premium"
    
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
            }
            self?.customerInfo = info
            if let info = info {
                self?.checkAndUpdateNonRenewingStatus(customerInfo: info)
                // Premium durumunu Firebase'e kaydet
                self?.updatePremiumStatusInFirebase()
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
        // Check if monthly subscription is active
        if let activeSubscriptions = customerInfo?.activeSubscriptions,
           activeSubscriptions.contains(monthlyProductID) {
            return true
        }
        
        // Check if user has premium entitlement or active lifetime purchase
        return customerInfo?.entitlements[premiumEntitlementID]?.isActive == true || isYearlyNonRenewingActive
    }
    
    func getSubscriptionType() -> AppUser.SubscriptionType {
        // Detaylı loglama ekleyelim
        print("Entitlement durumu: \(customerInfo?.entitlements[premiumEntitlementID]?.isActive)")
        print("Aktif abonelikler: \(customerInfo?.activeSubscriptions ?? [])")
        print("Ömür boyu abonelik durumu: \(isYearlyNonRenewingActive)")
        
        // Aylık abonelik kontrolü
        if let activeSubscriptions = customerInfo?.activeSubscriptions,
           activeSubscriptions.contains(monthlyProductID) {
            print("Aylık abonelik tespit edildi")
            return .premium
        }
        // Premium entitlement kontrolü
        else if customerInfo?.entitlements[premiumEntitlementID]?.isActive == true {
            print("Premium entitlement aktif")
            return .premium
        }
        // Ömür boyu abonelik kontrolü
        else if isYearlyNonRenewingActive {
            print("Ömür boyu abonelik aktif")
            return .pro
        } else {
            return .free
        }
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
                    print("RevenueCat user identity set: \(user.uid), new user: \(created)")
                    
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
            print("Firebase oturumu yok, premium durumu güncellenemedi")
            return
        }
        
        let subscriptionType = getSubscriptionType()
        let isPremium = subscriptionType != .free  // Convert to boolean
        
        print("Firebase'e yazılıyor - isPremium: \(isPremium), subscriptionType: \(subscriptionType)")
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "isPremium": isPremium,  // Now correctly storing a boolean
            "subscriptionType": subscriptionType.rawValue,
            "subscriptionUpdatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Premium durumu Firebase'e kaydedilemedi: \(error.localizedDescription)")
            } else {
                print("Premium durumu Firebase'e başarıyla kaydedildi: \(subscriptionType)")
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
