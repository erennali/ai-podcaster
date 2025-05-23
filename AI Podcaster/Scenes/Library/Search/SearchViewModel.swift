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
    private let podcastService: PodcastsServiceProtocol
    private let filterService: PodcastFilterServiceProtocol
    
    private(set) var searchResults: [Podcast] = []
    private(set) var filterConfiguration: PodcastFilterConfiguration = PodcastFilterConfiguration()
    
    init(
        podcastService: PodcastsServiceProtocol = PodcastsService(),
        filterService: PodcastFilterServiceProtocol = PodcastFilterService()
    ) {
        self.podcastService = podcastService
        self.filterService = filterService
    }
    
    func searchPodcasts(with query: String) {
        guard !query.isEmpty else {
            searchResults = []
            delegate?.didUpdateSearchResults()
            return
        }
        
        podcastService.searchPodcasts(query: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let podcasts):
                    // Apply filter/sort to search results
                    self.searchResults = self.filterService.filterAndSortPodcasts(podcasts, with: self.filterConfiguration)
                    self.delegate?.didUpdateSearchResults()
                case .failure(let error):
                    self.delegate?.didFailToSearch(with: error.localizedDescription)
                }
            }
        }
    }
    
    func updateFilter(configuration: PodcastFilterConfiguration) {
        filterConfiguration = configuration
        // Re-apply search with new filter if there's an ongoing search
        // This could be enhanced to remember the last search query
    }
} 