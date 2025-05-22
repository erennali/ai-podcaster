//
//  SearchViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

protocol SearchViewModelDelegate: AnyObject {
    func didUpdateSearchResults()
    func didFailToSearch(with error: String)
}

class SearchViewModel {
    
    weak var delegate: SearchViewModelDelegate?
    
    private(set) var searchResults: [Podcast] = []
    
    func searchPodcasts(with query: String) {
        guard !query.isEmpty else {
            searchResults = []
            delegate?.didUpdateSearchResults()
            return
        }
        
        // Burada gerçek bir arama işlemi yapılabilir
        // Örnek olarak boş bir implementasyon ekliyorum
        // Gerçek projede PodcastsService kullanılabilir
        
        // Örnek:
        // PodcastsService.shared.searchPodcasts(query: query) { [weak self] result in
        //     switch result {
        //     case .success(let podcasts):
        //         self?.searchResults = podcasts
        //         self?.delegate?.didUpdateSearchResults()
        //     case .failure(let error):
        //         self?.delegate?.didFailToSearch(with: error.localizedDescription)
        //     }
        // }
    }
} 