//
//  Podcast.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 15.05.2025.
//

import Foundation
import FirebaseCore

struct Podcast: Codable {
    let userId: UUID
    let title: String
    let content: String
    let minutes: Int
    let style: String
    let language: String
    let duration : Int
    let createdAt: Timestamp
}
