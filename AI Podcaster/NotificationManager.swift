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
    
    // Kullanıcının daha önce izin isteyip istemediğimizi takip etmek için key
    private let permissionRequestedKey = "notificationPermissionRequested"
    
    // Bildirim tanımlayıcısı
    private let notificationIdentifier = "DailyPodcastReminder"
    
    private let podcastMessages = [
        "Bugün podcast dinlemek ister misin? Yeni içerikler seni bekliyor!",
        "Podcast zamanı! Bugün kendine biraz bilgi katmaya ne dersin?",
        "Yeni bir podcast keşfetmeye hazır mısın? Hemen uygulamamıza göz at!",
        "Bugün kendi sesinden bir podcast oluşturmayı deneyelim mi?",
        "Podcast'ler seni bekliyor! Bugün yeni bir şeyler öğrenmeye ne dersin?",
        "AI ile kendi podcast'ini oluşturma zamanı! Hemen başla!",
        "Günün podcast saati geldi! İlham verici içerikler keşfet!",
        "Kendini geliştirmenin en kolay yolu: Bugün bir podcast dinle!",
        "Bugün sesli bir yolculuğa çıkmaya ne dersin? Podcast'ler hazır!",
        "AI destekli podcast'ler ile bugün yaratıcılığını konuştur!"
    ]
    
    private init() {
        // Başlangıçta daha önce istenmişse isRequested = ture
        isRequested = UserDefaults.standard.bool(forKey: permissionRequestedKey)
    }
    
    // İzin iste ve izin verilirse bildirimleri zamanla
    func requestNotificationPermissionWithAsync() async throws {
        let result = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        isRequested = true
        UserDefaults.standard.set(true, forKey: permissionRequestedKey)
        
        print("AUTHORIZATION RESULT: \(result)")
        
        if result {
            await scheduleDailyNotification()
        }
    }
    
    // Mevcut bildirim iznini güncelle
    @discardableResult
    func updateNotificationStatus() async -> UNAuthorizationStatus {
        let status = await center.notificationSettings().authorizationStatus
        notificationSettings = status
        return status
    }
    
    func scheduleDailyNotification() async {
        // Önce mevcut bildirimleri temizle - bu eski veya bekleyen bildirimleri önler
        center.removeAllPendingNotificationRequests()
        
        guard isAuthorized else { return }

        let randomMessage = podcastMessages.randomElement() ?? podcastMessages[0]
        
        // BUGÜN için bildirimi sadece GELECEK saatler için planla
        // Örneğin şu an 11:00 ise, bugün bildirim gönderilmeyecek
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        var tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now

        tomorrow = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        
        let tomorrowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: tomorrow)
        
        // Bildirim içeriği
        let content = UNMutableNotificationContent()
        content.title = "AI Podcaster"
        content.body = randomMessage
        content.sound = .default
        
        // Önce yarın için kesin bir bildirim zamanla
        let firstTrigger = UNCalendarNotificationTrigger(dateMatching: tomorrowComponents, repeats: false)
        
        let firstRequest = UNNotificationRequest(
            identifier: "\(notificationIdentifier)-once",
            content: content,
            trigger: firstTrigger
        )
        
        // Ardından her gün saat 10:00 için bir tekrarlayan bildirim zamanla
        var dailyComponents = DateComponents()
        dailyComponents.hour = 10
        dailyComponents.minute = 00
        
        let dailyTrigger = UNCalendarNotificationTrigger(dateMatching: dailyComponents, repeats: true)
        
        let dailyRequest = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: dailyTrigger
        )
        
        // Bildirimleri zamanla
        do {
            // Önce yarın için kesin bir bildirim zamanla
            try await center.add(firstRequest)
            
            // Ardından tekrarlayan günlük bildirimi zamanla
            try await center.add(dailyRequest)
            
            print("Bildirimler zamanlandı: İlk bildirim yarın saat 10:00, sonrasında her gün 10:00")
            print("Bildirim mesajı: \(randomMessage)")
        } catch {
            print("Bildirim zamanlama hatası: \(error)")
        }
    }
    
    func handleNotificationStatusChange() async {
        await updateNotificationStatus()
        
        if isAuthorized {
            center.removeAllPendingNotificationRequests()
            await scheduleDailyNotification()
        } else {
            // İzin yoksa, tüm bildirimleri temizle
            center.removeAllPendingNotificationRequests()
        }
    }
}

