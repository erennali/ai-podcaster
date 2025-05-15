//
//  PodcastsService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 15.05.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol PodcastsServiceProtocol {
    func fetchPodcasts(completion: @escaping (Result<[Podcast], Error>) -> Void)
    func savePodcast(_ podcast: Podcast, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePodcast(_ podcastId: String, completion: @escaping (Result<Void, Error>) -> Void)
}
    
