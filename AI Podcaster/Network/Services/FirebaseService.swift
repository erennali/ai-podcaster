//
//  FirebaseService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 9.05.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private var userData: [String: Any]?
    
    private init() {}
    
    func fetchUserData() async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .getDocument()
            
            if let data = document.data() {
                self.userData = data
                
                // RevenueCat'ten premium durumu kontrol et ve Firebase ile senkronize et
                if let isPremium = IAPService.shared.isPremiumUser() ? true : false,
                   let isPremiumInFirebase = data["isPremium"] as? Bool,
                   isPremium != isPremiumInFirebase {
                    // Eğer durum farklıysa güncelle
                    IAPService.shared.updatePremiumStatusInFirebase()
                }
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    func getUserData() -> [String: Any]? {
        return userData
    }
    
    func getUserSubscriptionStatus() -> Bool {
        if let userData = userData, let isPremium = userData["isPremium"] as? Bool {
            return isPremium
        }
        return false
    }
    
    func getUserSubscriptionType() -> AppUser.SubscriptionType {
        if let userData = userData, let subscriptionTypeString = userData["subscriptionType"] as? String {
            return AppUser.SubscriptionType(rawValue: subscriptionTypeString) ?? .free
        }
        return .free
    }
    func clearUserData() {
        userData = nil
    }
    
    func updateUserData(with data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı"]))
            return
        }
        
        Firestore.firestore().collection("users").document(user.uid).updateData(data) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
                completion?(error)
            } else {
                // Başarılı güncelleme durumunda userData'yı da güncelle
                if var currentUserData = self.userData {
                    for (key, value) in data {
                        currentUserData[key] = value
                    }
                    self.userData = currentUserData
                }
                completion?(nil)
            }
        }
    }
    
}

