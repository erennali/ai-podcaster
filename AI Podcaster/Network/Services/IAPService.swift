import Foundation
import RevenueCat
import Combine

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
        
        // Fetch initial data
        fetchCustomerInfo()
        fetchOfferings()
    }
    
    // MARK: - PurchasesDelegate Methods
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        checkAndUpdateNonRenewingStatus(customerInfo: customerInfo)
        
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
            
            // Notify subscription status changed
            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
            
            completion(.success(customerInfo))
        }
    }
    
    func restorePurchases(completion: @escaping (Result<CustomerInfo, Error>) -> Void) {
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
            
            // Notify subscription status changed
            NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
            
            completion(.success(customerInfo))
        }
    }
    
    // MARK: - Subscription Status
    func isPremiumUser() -> Bool {
        // Check if user has premium entitlement or active lifetime purchase
        return customerInfo?.entitlements[premiumEntitlementID]?.isActive == true || isYearlyNonRenewingActive
    }
    
    func getSubscriptionType() -> AppUser.SubscriptionType {
        if customerInfo?.entitlements[premiumEntitlementID]?.isActive == true {
            return .premium
        } else if isYearlyNonRenewingActive {
            return .pro
        } else {
            return .free
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