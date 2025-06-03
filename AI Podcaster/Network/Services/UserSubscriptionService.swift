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
                  let data = snapshot?.data(),
                  let isPremiumString = data["isPremium"] as? String else {
                completion(.unknown)
                return
            }
            
            // Check if user is premium
            if isPremiumString != "free" {
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
                let message = "You have \(daysLeft) day\(daysLeft == 1 ? "" : "s") left in your free trial. Don't forget to upgrade to Premium!"
                completion(true, message)
                
            case .freeTrialExpired:
                // Trial expired, no access
                completion(false, "Your 7-day free trial has expired. Please upgrade to continue using this feature.")
                
            case .unknown:
                // Unknown status, default to no access
                completion(false, "Unable to verify subscription status. Please try again later.")
            }
        }
    }
} 
