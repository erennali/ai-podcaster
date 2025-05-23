//
//  PodcastsViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 20.05.2025.
//

import Foundation

protocol PodcastsViewModelDelegate: AnyObject {
    func didUpdatePodcasts()
    func didShowError(_ error: String)
}

final class PodcastsViewModel {
    
    // MARK: - Properties
    private let podcastService: PodcastsServiceProtocol
    private let filterService: PodcastFilterServiceProtocol
    weak var delegate: PodcastsViewModelDelegate?
    
    private(set) var allPodcasts: [Podcast] = []
    private(set) var filteredPodcasts: [Podcast] = []
    private(set) var currentFilterConfiguration: PodcastFilterConfiguration = PodcastFilterConfiguration()
    
    // Public getter for displayed podcasts
    var podcasts: [Podcast] {
        return filteredPodcasts
    }
    
    init(
        podcastService: PodcastsServiceProtocol = PodcastsService(),
        filterService: PodcastFilterServiceProtocol = PodcastFilterService()
    ) {
        self.podcastService = podcastService
        self.filterService = filterService
    }
    
    // MARK: - Public Methods
    func fetchPodcasts() {
        podcastService.fetchPodcasts { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let podcasts):
                self.allPodcasts = podcasts
                self.applyCurrentFilter()
            case .failure(let error):
                self.delegate?.didShowError(error.localizedDescription)
            }
        }
    }
    
    func updateFilter(configuration: PodcastFilterConfiguration) {
        currentFilterConfiguration = configuration
        applyCurrentFilter()
    }
    
    func resetFilter() {
        currentFilterConfiguration = PodcastFilterConfiguration()
        applyCurrentFilter()
    }
    
    func getAvailableStyles() -> [String] {
        return filterService.getAvailableStyles(from: allPodcasts)
    }
    
    func getAvailableLanguages() -> [String] {
        return filterService.getAvailableLanguages(from: allPodcasts)
    }
    
    var hasActiveFilters: Bool {
        return !currentFilterConfiguration.isDefault
    }
    
    var activeFiltersCount: Int {
        return currentFilterConfiguration.filterOptions.activeFiltersCount
    }
}

// MARK: - Private Methods
private extension PodcastsViewModel {
    func applyCurrentFilter() {
        filteredPodcasts = filterService.filterAndSortPodcasts(allPodcasts, with: currentFilterConfiguration)
        delegate?.didUpdatePodcasts()
    }
}
