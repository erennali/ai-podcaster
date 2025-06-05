//
//  UserSubscriptionService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 6.06.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Protocol
protocol UserSubscriptionServiceProtocol {
    func checkSubscriptionStatus(completion: @escaping (SubscriptionStatus) -> Void)
    func isFreePremiumFeatureAccessible(completion: @escaping (Bool, String?) -> Void)
}

// MARK: - Subscription Status Enum
enum SubscriptionStatus {
    case premium
    case freeTrial(daysLeft: Int)
    case freeTrialExpired
    case unknown
}

// MARK: - Implementation
final class UserSubscriptionService: UserSubscriptionServiceProtocol {
    // MARK: - Singleton
    static let shared = UserSubscriptionService()
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let trialPeriodDays = 7
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func checkSubscriptionStatus(completion: @escaping (SubscriptionStatus) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.unknown)
            return
        }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            guard error == nil,
                  let data = snapshot?.data() else {
                completion(.unknown)
                return
            }
            
            // Check if user is premium - handle both Boolean and String formats
            if let isPremiumBool = data["isPremium"] as? Bool {
                if isPremiumBool {
                    completion(.premium)
                    return
                }
            } else if let isPremiumString = data["isPremium"] as? String, isPremiumString != "free" {
                completion(.premium)
                return
            }
            
            // User is free, check trial period
            guard let createdAt = data["createdAt"] as? Timestamp else {
                completion(.unknown)
                return
            }
            
            let creationDate = createdAt.dateValue()
            let currentDate = Date()
            
            // Calculate days since registration
            let daysSinceRegistration = Calendar.current.dateComponents([.day], from: creationDate, to: currentDate).day ?? 0
            
            if daysSinceRegistration < self.trialPeriodDays {
                // User is in trial period
                let daysLeft = self.trialPeriodDays - daysSinceRegistration
                completion(.freeTrial(daysLeft: daysLeft))
            } else {
                // Trial period expired
                completion(.freeTrialExpired)
            }
        }
    }
    
    func isFreePremiumFeatureAccessible(completion: @escaping (Bool, String?) -> Void) {
        checkSubscriptionStatus { status in
            switch status {
            case .premium:
                // Premium users always have access
                completion(true, nil)
                
            case .freeTrial(let daysLeft):
                // Free trial users have access, inform them of days left
                let message = SceneDelegate.appLanguageName == "Türkçe" ?
                    "Premium özelliklere erişiminiz var. Deneme süreniz \(daysLeft) gün sonra sona erecek." :
                    "You have access to premium features. Your trial ends in \(daysLeft) days."
                    
                completion(true, message)
                
            case .freeTrialExpired:
                // Trial expired, no access
                completion(false, NSLocalizedString("trialExpired", comment: ""))
                
            case .unknown:
                // Unknown status, default to no access
                completion(false, NSLocalizedString("unableToSub", comment: ""))
            }
        }
    }
}
