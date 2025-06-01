//
//  HomeViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel {
    
    private let motivationKey = "dailyMotivationText"
    private let motivationDateKey = "dailyMotivationDate"
    private let motivationRefreshHour = 9 // Sabah 9'da yenilenecek
    private let firebaseService = FirebaseService.shared
    private let firestore = Firestore.firestore()
    
    var dailyMotivation: String? {
        UserDefaults.standard.string(forKey: motivationKey)
    }
    
    func updateDailyMotivation(_ text: String) {
        UserDefaults.standard.setValue(text, forKey: motivationKey)
        UserDefaults.standard.setValue(Date(), forKey: motivationDateKey)
    }
    
    func shouldFetchMotivation() -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: motivationDateKey) as? Date else {
            return true
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Önce tarih kontrolü yap
        if !calendar.isDateInToday(lastDate) {
            // Farklı bir gündeyiz
            
            // Şu anki saat 9'dan büyük veya eşitse (09:00 veya sonrası) yeni motivasyon çekilmeli
            let currentHour = calendar.component(.hour, from: currentDate)
            return currentHour >= motivationRefreshHour
        }
        
        // Aynı gündeyiz, son güncelleme saat 9'dan önce mi yapılmış?
        let lastUpdateHour = calendar.component(.hour, from: lastDate)
        let currentHour = calendar.component(.hour, from: currentDate)
        
        // Son güncelleme 9'dan önce ve şu an 9 veya sonrası ise güncelle
        return lastUpdateHour < motivationRefreshHour && currentHour >= motivationRefreshHour
    }
    
    func getUserName() -> String {
        if let userData = firebaseService.getUserData(),
           let name = userData["name"] as? String {
            return name
        }
        return "User"
    }

//    func getPodcastCount(completion: @escaping (Int) -> Void) {
//        let userId = Auth.auth().currentUser?.uid ?? ""
//        
//        firestore.collection("users").document(userId).collection("podcasts").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching podcasts: \(error.localizedDescription)")
//                completion(0)
//                return
//            }
//            
//            let podcastCount = snapshot?.documents.count ?? 0
//            completion(podcastCount)
//        }
//    }
    func getPodcastCount(completion: @escaping (Int) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else {
            completion(0)
            return
        }
        
        firestore.collection("users").document(userId).collection("podcasts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching podcasts: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            let podcastCount = snapshot?.documents.count ?? 0
            completion(podcastCount)
        }
    }
    
    
}
