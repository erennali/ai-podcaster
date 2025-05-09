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
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    func getUserData() -> [String: Any]? {
        return userData
    }
}

