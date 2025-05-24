//
//  NotificationManager.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 24.05.2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
    
    public static let shared = NotificationManager()
    private var center = UNUserNotificationCenter.current()
    public var isRequested = false
    
    private var notificationSettings: UNAuthorizationStatus = .notDetermined
    public var isAuthorized: Bool {
        notificationSettings == .authorized
    }
    private init() {}
    
    func requestNotificationPermissionWithAsync() async throws {
     let result = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        isRequested = true
        print("AUTHORIZATION RESULT: \(result)")
        
    }
    @discardableResult
    func updateNotificationStatus() async -> UNAuthorizationStatus {
        let status = await center.notificationSettings().authorizationStatus
        notificationSettings = status
        return status
    }
        
}

