//
//  SettingsViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 10.05.2025.
//

import Foundation
import UserNotifications
import FirebaseAuth

class SettingsViewModel {
    
    var sections = SettingsSection.sections
    private let themeKey = "selectedTheme"
    
    init() {
    }
    
}


// MARK: - Methods

extension SettingsViewModel {
    func fetchThemeMode() -> Int {
        UserDefaults.standard.integer(forKey: themeKey)
    }
    func updateNotificationStatus(isOn: Bool) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Notification permission granted: \(granted)")
        }
    }
    
    func fetchNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
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
}
