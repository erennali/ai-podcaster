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
    private let homeViewModel = HomeViewModel()
    
    func loadInitialData() {
        let delegate = self.delegate
        Task {
            await FirebaseService.shared.fetchUserData()
            
            if homeViewModel.shouldFetchMotivation() {
                GoogleAIService.shared.fetchDailyMotivation { [weak self] result in
                    switch result {
                    case .success(let text):
                        self?.homeViewModel.updateDailyMotivation(text)
                    case .failure:
                        break // Hata olursa eski motivasyon gösterilir
                    }
                    DispatchQueue.main.async {
                        delegate?.didFinishLoading()
                    }
                }
            } else {
                await MainActor.run {
                    delegate?.didFinishLoading()
                }
            }
        }
    }
}
