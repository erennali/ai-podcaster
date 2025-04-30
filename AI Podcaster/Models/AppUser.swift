//
//  AppUser.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 30.04.2025.
//

import Foundation

struct UsersModel: Codable {
    let users: [AppUser]
}

struct AppUser: Codable {
    let id: String
    let email: String
    let name: String
    let profileImageUrl: String?
    let subscriptionType: SubscriptionType
    let isPremium: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum SubscriptionType: String, Codable {
        case free
        case premium
        case pro
    }
}
