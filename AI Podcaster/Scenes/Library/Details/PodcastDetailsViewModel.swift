//
//  PodcastDetailsViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 22.05.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PodcastDetailsViewModel {
    
    let podcast: Podcast
    private let podcastService: PodcastsServiceProtocol
    
    init(podcast: Podcast, podcastService: PodcastsServiceProtocol = PodcastsService()) {
        self.podcast = podcast
        self.podcastService = podcastService
    }
    
    func deletePodcast(completion: @escaping (Result<Void, Error>) -> Void) {
        podcastService.deletePodcast(podcast.id) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
