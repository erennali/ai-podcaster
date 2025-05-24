//
//  PodcastFilterService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

protocol PodcastFilterServiceProtocol {
    func filterAndSortPodcasts(_ podcasts: [Podcast], with configuration: PodcastFilterConfiguration) -> [Podcast]
    func getAvailableStyles(from podcasts: [Podcast]) -> [String]
    func getAvailableLanguages(from podcasts: [Podcast]) -> [String]
}

final class PodcastFilterService: PodcastFilterServiceProtocol {
    
    // MARK: - Public Methods
    func filterAndSortPodcasts(_ podcasts: [Podcast], with configuration: PodcastFilterConfiguration) -> [Podcast] {
        var filteredPodcasts = applyFilters(to: podcasts, with: configuration.filterOptions)
        filteredPodcasts = applySorting(to: filteredPodcasts, with: configuration.sortType)
        return filteredPodcasts
    }
    
    func getAvailableStyles(from podcasts: [Podcast]) -> [String] {
        let styles = Set(podcasts.map { $0.style })
        let availableStyles = Array(styles).sorted()
        
        // Eğer podcast'ler yoksa veya style'lar boşsa, predefined seçenekleri kullan
        return availableStyles.isEmpty ? PodcastOptions.availableStyles : availableStyles
    }
    
    func getAvailableLanguages(from podcasts: [Podcast]) -> [String] {
        let languages = Set(podcasts.map { $0.language })
        let availableLanguages = Array(languages).sorted()
        
        // Eğer podcast'ler yoksa veya language'lar boşsa, predefined seçenekleri kullan
        return availableLanguages.isEmpty ? PodcastOptions.availableLanguages : availableLanguages
    }
}

// MARK: - Private Methods
private extension PodcastFilterService {
    
    func applyFilters(to podcasts: [Podcast], with filterOptions: FilterOptions) -> [Podcast] {
        return podcasts.filter { podcast in
            return passesStyleFilter(podcast, filterOptions) &&
                   passesLanguageFilter(podcast, filterOptions) &&
                   passesDurationFilter(podcast, filterOptions)
        }
    }
    
    func passesStyleFilter(_ podcast: Podcast, _ filterOptions: FilterOptions) -> Bool {
        // If no styles are selected, don't filter by style (pass all)
        guard !filterOptions.selectedStyles.isEmpty else { return true }
        // Only pass podcasts with styles that are in the selected styles set
        return filterOptions.selectedStyles.contains(podcast.style)
    }
    
    func passesLanguageFilter(_ podcast: Podcast, _ filterOptions: FilterOptions) -> Bool {
        // If no languages are selected, don't filter by language (pass all)
        guard !filterOptions.selectedLanguages.isEmpty else { return true }
        // Only pass podcasts with languages that are in the selected languages set
        return filterOptions.selectedLanguages.contains(podcast.language)
    }
    
    func passesDurationFilter(_ podcast: Podcast, _ filterOptions: FilterOptions) -> Bool {
        // If no duration range is selected, don't filter by duration (pass all)
        guard let durationRange = filterOptions.selectedDurationRange else { return true }
        // Only pass podcasts with duration in the selected range
        return podcast.minutes >= durationRange.min && podcast.minutes <= durationRange.max
    }
    
    func applySorting(to podcasts: [Podcast], with sortType: SortType) -> [Podcast] {
        switch sortType {
        case .date(let order):
            return sortByDate(podcasts, order: order)
        case .title(let order):
            return sortByTitle(podcasts, order: order)
        }
    }
    
    func sortByDate(_ podcasts: [Podcast], order: DateSortOrder) -> [Podcast] {
        switch order {
        case .newest:
            return podcasts.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
        case .oldest:
            return podcasts.sorted { $0.createdAt.dateValue() < $1.createdAt.dateValue() }
        }
    }
    
    func sortByTitle(_ podcasts: [Podcast], order: TitleSortOrder) -> [Podcast] {
        switch order {
        case .aToZ:
            return podcasts.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .zToA:
            return podcasts.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }
    }
} 