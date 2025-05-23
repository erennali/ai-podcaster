//
//  ChatMessage.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: String
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(text: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = UUID().uuidString
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

// MARK: - Message Type Enum
enum MessageType {
    case user
    case ai
    case error
    case loading
}

// MARK: - Chat State
enum ChatState: Equatable {
    case idle
    case loading
    case error(String)
    
    // Equatable implementation for associated values
    static func == (lhs: ChatState, rhs: ChatState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
} 