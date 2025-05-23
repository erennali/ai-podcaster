//
//  PodcastTest.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import Foundation
import UIKit

struct WelcomeCollectionView {
    let title: String
    let description: String
    let imageName: String?
    let destinationType: CellDestination
    
    init(title: String, description: String, imageName: String? = nil, destinationType: CellDestination = .details) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.destinationType = destinationType
    }
}

enum CellDestination {
    case chat
    case create
    case details
}
