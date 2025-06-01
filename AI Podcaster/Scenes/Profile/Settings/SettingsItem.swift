//
//  SettingsItem.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 10.05.2025.
//

import Foundation

enum SettingsItemType {
    case theme
    case notification
    case deleteAccount
    case rateApp
    case privacyPolicy
    case termsOfUse
    case subscription
    case restorePurchases
}

struct SettingsItem {
    let title: String
    let iconName: String
    let type: SettingsItemType
}

struct SettingsSection {
    let title: String
    let items: [SettingsItem]
    
    static let sections: [SettingsSection] = [
        SettingsSection(title: "Appearance", items: [
            SettingsItem(title: "App Theme", iconName: "circle.righthalf.filled", type: .theme),
        ]),
        SettingsSection(title: "Notifications", items: [
            SettingsItem(title: "Notification", iconName: "bell.fill", type: .notification),
        ]),
        SettingsSection(title: "Premium", items: [
            SettingsItem(title: "Üyelik Planları", iconName: "crown.fill", type: .subscription),
            SettingsItem(title: "Satın Alımları Geri Yükle", iconName: "arrow.clockwise", type: .restorePurchases),
        ]),
        SettingsSection(title: "Rate Us", items: [
            SettingsItem(title: "Rate Us", iconName: "star.fill", type: .rateApp),
        ]),
        SettingsSection(title: "Delete Account", items: [
            SettingsItem(title: "Delete Account", iconName: "person.crop.circle.fill.badge.minus", type: .deleteAccount),
        ]),
        SettingsSection(title: "Legal", items: [
            SettingsItem(title: "Privacy Policy", iconName: "text.document.fill", type: .privacyPolicy),
            SettingsItem(title: "Terms of Use", iconName: "checkmark.shield.fill", type: .termsOfUse),
        ])
    ]
}
