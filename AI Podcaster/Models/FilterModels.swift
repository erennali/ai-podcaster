//
//  FilterModels.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

// MARK: - Sort Options
enum SortType {
    case date(DateSortOrder)
    case title(TitleSortOrder)
}

enum DateSortOrder: String, CaseIterable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    
    var displayName: String {
        return self.rawValue
    }
}

enum TitleSortOrder: String, CaseIterable {
    case aToZ = "A to Z"
    case zToA = "Z to A"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Filter Options
struct FilterOptions {
    var selectedStyles: Set<String>
    var selectedLanguages: Set<String>
    var selectedDurationRange: DurationRange?
    
    init() {
        self.selectedStyles = []
        self.selectedLanguages = []
        self.selectedDurationRange = nil
    }
    
    var isActive: Bool {
        return !selectedStyles.isEmpty || 
               !selectedLanguages.isEmpty || 
               selectedDurationRange != nil
    }
    
    var activeFiltersCount: Int {
        var count = 0
        if !selectedStyles.isEmpty { count += 1 }
        if !selectedLanguages.isEmpty { count += 1 }
        if selectedDurationRange != nil { count += 1 }
        return count
    }
}

struct DurationRange {
    let min: Int
    let max: Int
    
    // Gerçek podcast duration'larına göre güncellendi (5-10 dakika)
    static let short = DurationRange(min: 5, max: 6)      // 5-6 dakika
    static let medium = DurationRange(min: 7, max: 8)     // 7-8 dakika  
    static let long = DurationRange(min: 9, max: 10)      // 9-10 dakika
    
    static let allRanges: [DurationRange] = [.short, .medium, .long]
    
    var displayName: String {
        switch self {
        case DurationRange.short:
            return "5-6 min"
        case DurationRange.medium:
            return "7-8 min"
        case DurationRange.long:
            return "9-10 min"
        default:
            return "Custom (\(min)-\(max) min)"
        }
    }
}

extension DurationRange: Equatable {
    static func == (lhs: DurationRange, rhs: DurationRange) -> Bool {
        return lhs.min == rhs.min && lhs.max == rhs.max
    }
}

extension DurationRange: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(min)
        hasher.combine(max)
    }
}

// MARK: - Filter and Sort Configuration
struct PodcastFilterConfiguration {
    var sortType: SortType
    var filterOptions: FilterOptions
    
    init() {
        self.sortType = .date(.newest)
        self.filterOptions = FilterOptions()
    }
    
    var isDefault: Bool {
        switch sortType {
        case .date(.newest):
            return !filterOptions.isActive
        default:
            return false
        }
    }
}

// MARK: - Predefined Options
struct PodcastOptions {
    // CreaterPodcastsViewController'dan alınan gerçek style seçenekleri
    static let availableStyles = ["Technical", "Fun", "Professional", "Companion"]
    
    // CreaterPodcastsViewModel'dan alınan gerçek language seçenekleri
    static let availableLanguages = [
        "Türkçe", "English (US)", "English (UK)", "Español", "Français", 
        "Deutsch", "Italiano", "Português", "Русский", "日本語", "한국어", "中文", "العربية"
    ]
} 
