//
//  SplashViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

protocol SplashViewModelDelegate: AnyObject {
    func didFinishLoading()
    func didFailLoading(with error: String)
}

// Swift concurrency için @Sendable uyumluluğu ekleyelim
@available(iOS 13.0, *)
final class SplashViewModel: @unchecked Sendable {
    
    weak var delegate: SplashViewModelDelegate?
    
    func loadInitialData() {
        // Önce self referansını dışarı alalım
        let delegate = self.delegate
        
        Task {
            // FirebaseService'deki fetchUserData() fonksiyonu hata fırlatmıyor
            await FirebaseService.shared.fetchUserData()
            
            // Main thread'e geçiş yapalım
            await MainActor.run {
                delegate?.didFinishLoading()
            }
        }
    }
} 
