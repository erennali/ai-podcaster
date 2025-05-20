//
//  PodcastsViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 20.05.2025.
//

import Foundation

final class PodcastsViewModel {
    
    // MARK: - Properties
    private let podcastService: PodcastsServiceProtocol
    weak var delegate: PodcastsViewControllerProtocol?
    
    private(set) var podcasts: [Podcast] = []
    
    init(podcastService: PodcastsServiceProtocol = PodcastsService()) {
        
        self.podcastService = podcastService
    }
    
    
}

extension PodcastsViewModel {
    
    func fetchPodcasts() {
        podcastService.fetchPodcasts { [weak self] result  in
            guard let self = self else { return }
            
            switch result {
            case .success(let podcasts):
                self.podcasts = podcasts
                self.delegate?.reloadData()
            case .failure(let error):
                print("Error fetching podcasts: \(error.localizedDescription)")
                
            }
        }
    }
        
    
}
