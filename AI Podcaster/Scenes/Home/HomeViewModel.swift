//
//  HomeViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import Foundation

class HomeViewModel {
    
    func getUserName() -> String {
        if let userData = FirebaseService.shared.getUserData(),
           let name = userData["name"] as? String {
            return name
        }
        return "User"
    }
}
