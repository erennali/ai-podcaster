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

class SplashViewModel {
    
    weak var delegate: SplashViewModelDelegate?
    
    func loadInitialData() {
        Task {
            do {
                try await FirebaseService.shared.fetchUserData()
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFinishLoading()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailLoading(with: error.localizedDescription)
                }
            }
        }
    }
} 