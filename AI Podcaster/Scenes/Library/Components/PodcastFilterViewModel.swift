//
//  PodcastFilterViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

protocol PodcastFilterViewModelDelegate: AnyObject {
    func didUpdateConfiguration(_ configuration: PodcastFilterConfiguration)
    func didUpdateAvailableOptions(styles: [String], languages: [String])
}

final class PodcastFilterViewModel {
    
    // MARK: - Properties
    weak var delegate: PodcastFilterViewModelDelegate?
    private let filterService: PodcastFilterServiceProtocol
    
    private(set) var currentConfiguration: PodcastFilterConfiguration
    private(set) var availableStyles: [String] = []
    private(set) var availableLanguages: [String] = []
    private(set) var allPodcasts: [Podcast] = []
    
    // MARK: - Initialization
    init(filterService: PodcastFilterServiceProtocol = PodcastFilterService()) {
        self.filterService = filterService
        self.currentConfiguration = PodcastFilterConfiguration()
    }
    
    // MARK: - Public Methods
    func setupWithPodcasts(_ podcasts: [Podcast]) {
        allPodcasts = podcasts
        
        // Get available styles and languages from podcasts
        availableStyles = filterService.getAvailableStyles(from: podcasts)
        availableLanguages = filterService.getAvailableLanguages(from: podcasts)
        
        // Log the available options for debugging
        print("Available styles: \(availableStyles)")
        print("Available languages: \(availableLanguages)")
        
        // Notify delegate about the available options
        delegate?.didUpdateAvailableOptions(styles: availableStyles, languages: availableLanguages)
    }
    
    func updateSortType(_ sortType: SortType) {
        currentConfiguration.sortType = sortType
        delegate?.didUpdateConfiguration(currentConfiguration)
    }
    
    func toggleStyleFilter(_ style: String) {
        if currentConfiguration.filterOptions.selectedStyles.contains(style) {
            currentConfiguration.filterOptions.selectedStyles.remove(style)
        } else {
            currentConfiguration.filterOptions.selectedStyles.insert(style)
        }
        
        print("Style filter toggled: \(style). Selected styles: \(currentConfiguration.filterOptions.selectedStyles)")
        delegate?.didUpdateConfiguration(currentConfiguration)
    }
    
    func toggleLanguageFilter(_ language: String) {
        if currentConfiguration.filterOptions.selectedLanguages.contains(language) {
            currentConfiguration.filterOptions.selectedLanguages.remove(language)
        } else {
            currentConfiguration.filterOptions.selectedLanguages.insert(language)
        }
        
        print("Language filter toggled: \(language). Selected languages: \(currentConfiguration.filterOptions.selectedLanguages)")
        delegate?.didUpdateConfiguration(currentConfiguration)
    }
    
    func updateDurationFilter(_ durationRange: DurationRange?) {
        currentConfiguration.filterOptions.selectedDurationRange = durationRange
        
        if let range = durationRange {
            print("Duration filter updated: \(range.displayName)")
        } else {
            print("Duration filter cleared")
        }
        
        delegate?.didUpdateConfiguration(currentConfiguration)
    }
    
    func resetToDefault() {
        currentConfiguration = PodcastFilterConfiguration()
        delegate?.didUpdateConfiguration(currentConfiguration)
    }
    
    // MARK: - Getters for UI
    func isStyleSelected(_ style: String) -> Bool {
        return currentConfiguration.filterOptions.selectedStyles.contains(style)
    }
    
    func isLanguageSelected(_ language: String) -> Bool {
        return currentConfiguration.filterOptions.selectedLanguages.contains(language)
    }
    
    func isDurationRangeSelected(_ range: DurationRange) -> Bool {
        if let selectedRange = currentConfiguration.filterOptions.selectedDurationRange {
            return selectedRange.min == range.min && selectedRange.max == range.max
        }
        return false
    }
    
    func getCurrentSortDisplayName() -> String {
        switch currentConfiguration.sortType {
        case .date(let order):
            return order.displayName
        case .title(let order):
            return order.displayName
        }
    }
    
    func getActiveFiltersCount() -> Int {
        return currentConfiguration.filterOptions.activeFiltersCount
    }
    
    var hasActiveFilters: Bool {
        return !currentConfiguration.isDefault
    }
    
    // SortType helpers (taşındı)
    var isSortTypeDate: Bool {
        switch currentConfiguration.sortType {
        case .date: return true
        case .title: return false
        }
    }
    
    func getSortSegmentTitles() -> [String] {
        return isSortTypeDate ? [NSLocalizedString("newest", comment: ""), NSLocalizedString("oldest", comment: "")] : [NSLocalizedString("a-z", comment: ""), NSLocalizedString("z-a", comment: "")]
    }
} 
