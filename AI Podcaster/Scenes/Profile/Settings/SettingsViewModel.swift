//
//  SettingsViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 10.05.2025.
//

import Foundation
import UserNotifications
import FirebaseAuth
import RevenueCat

class SettingsViewModel {
    
    // MARK: - Properties
    var sections = SettingsSection.sections
    private let themeKey = "selectedTheme"
    private var notificationManager: NotificationManager = .shared
    private let iapService = IAPService.shared
    
    weak var delegate: SettingsViewControllerProtocol?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleReturnFromSettings), name: .didReturnFromSettings, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusChanged), name: .subscriptionStatusChanged, object: nil)
    }
    
}


// MARK: - Methods

extension SettingsViewModel {
    func fetchThemeMode() -> Int {
        UserDefaults.standard.integer(forKey: themeKey)
    }
    func updateNotificationStatus(isOn: Bool) {
        
        Task {
            if !notificationManager.isRequested && isOn {
                try await notificationManager.requestNotificationPermissionWithAsync()
                await notificationManager.updateNotificationStatus()
                delegate?.updateSwitchValue(notificationManager.isAuthorized)
            } else {
                delegate?.openAppSettings()
            }
        }
    }
    
    func fetchNotificationStatus(completion: @escaping (Bool) -> Void) {
        completion(notificationManager.isAuthorized)
    }
    @objc func handleReturnFromSettings() {
        Task {
            await notificationManager.updateNotificationStatus()
            delegate?.updateSwitchValue(notificationManager.isAuthorized)
        }
    }
    func deleteAccount() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User deleted successfully.")
            }
        }
    }
    
    func getSubscriptionStatusText() -> String {
        if iapService.isPremiumUser() {
            let subscriptionType = iapService.getSubscriptionType()
            switch subscriptionType {
            case .premium:
                return "Aylık Premium"
            case .pro:
                return "Sınırsız Premium"
            case .free:
                return "Free"
            }
        } else {
            return "Free"
        }
    }
    
    func restorePurchases(completion: @escaping (Result<Void, Error>) -> Void) {
        iapService.restorePurchases { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @objc func subscriptionStatusChanged() {
        delegate?.updateSubscriptionStatusLabel(getSubscriptionStatusText())
    }
}

extension Notification.Name {
    static let didReturnFromSettings = Notification.Name("didReturnFromSettings")
}
