//
//  Podcast.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 15.05.2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Podcast: Codable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let minutes: Int
    let style: String
    let language: String
    let createdAt: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case content
        case minutes
        case style
        case language
        case duration
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        minutes = try container.decode(Int.self, forKey: .minutes)
        style = try container.decode(String.self, forKey: .style)
        language = try container.decode(String.self, forKey: .language)
        
        createdAt = try container.decode(Timestamp.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(minutes, forKey: .minutes)
        try container.encode(style, forKey: .style)
        try container.encode(language, forKey: .language)
        
        try container.encode(createdAt, forKey: .createdAt)
    }
}
