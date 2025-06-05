//
//  AppDelegate.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import FirebaseCore
import AVFoundation
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Uygulama başlatıldığında ses çalma kontrollerini aktif et
        setupAudioSession()
         
        // RevenueCat konfigürasyonu
        Purchases.configure(withAPIKey: NetworkConstants.revenueCatApiKey)
        Purchases.debugLogsEnabled = true
        
        // IAPService'i konfigüre et
        IAPService.shared.configure()
        
        // Bildirim durumunu kontrol et ve gerekirse izin iste
        checkNotificationStatus()
      
        // Kullanıcı verilerini önceden yükle
            Task {
                await FirebaseService.shared.fetchUserData()
            }
            
          
           
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // Arka planda ses çalma için genel audio session kurulumu
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Uzaktan kontrolleri etkinleştir
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    // Uygulama arka plana geçtiğinde çağrılır
    func applicationDidEnterBackground(_ application: UIApplication) {
        // AVSpeechService'in arka plan görevinin sürmesini sağla
        if AVSpeechService.shared.synthesizer.isSpeaking {
            print("App entered background with active speech")
        }
    }

    // Bildirim durumunu kontrol et
    private func checkNotificationStatus() {
        Task {
            let notificationManager = NotificationManager.shared
            
            await notificationManager.updateNotificationStatus()
            
            // ilk açılış ise izin iste
            if !notificationManager.isRequested {
                do {
                    try await notificationManager.requestNotificationPermissionWithAsync()
                } catch {
                    print("Bildirim izni isteme hatası: \(error)")
                }
            } 
            // Eğer bildirim izni zaten verilmişse ama bildirimler zamanlanmamışsa
            else if notificationManager.isAuthorized {
                await notificationManager.scheduleDailyNotification()
            }
        }
    }
}

