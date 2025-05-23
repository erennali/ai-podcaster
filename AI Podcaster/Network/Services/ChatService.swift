//
//  ChatService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import Foundation

// MARK: - Chat Service Protocol
protocol ChatServiceProtocol {
    func sendMessage(
        _ message: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    )
    func sendMessageWithHistory(
        _ message: String,
        history: [ChatMessage],
        completion: @escaping (Result<String, NetworkError>) -> Void
    )
}

// MARK: - Chat Service Implementation
final class ChatService: ChatServiceProtocol {
    
    // MARK: - Dependencies
    private let googleAIService: GoogleAIService
    
    // MARK: - Initialization
    init(googleAIService: GoogleAIService = .shared) {
        self.googleAIService = googleAIService
    }
    
    // MARK: - Public Methods
    func sendMessage(
        _ message: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        let podcastPrompt = createPodcastPrompt(for: message)
        
        googleAIService.generateAIResponse(prompt: podcastPrompt) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(.customError(error)))
            }
        }
    }
    
    func sendMessageWithHistory(
        _ message: String,
        history: [ChatMessage],
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        let contextualPrompt = createContextualPrompt(for: message, with: history)
        
        googleAIService.generateAIResponse(prompt: contextualPrompt) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(.customError(error)))
            }
        }
    }
}

// MARK: - Private Methods
private extension ChatService {
    
    func createPodcastPrompt(for message: String) -> String {
        return """
        You are an AI podcast expert assistant. Your role is to help users with podcast topics, content creation, storytelling, and audio content.
        
        User's message: \"\(message)\"
        
        Please:
        - Provide professional advice related to the podcast world
        - Offer creative and inspiring suggestions
        - Explain technical topics in simple and understandable terms
        - Respond in English
        - Use a friendly and helpful tone
        - Do NOT use ** or any markdown formatting for bold or emphasis
        
        Keep your response to a maximum of 120 words.
        """
    }
    
    func createContextualPrompt(for message: String, with history: [ChatMessage]) -> String {
        var contextString = ""
        
        // Get last 10 messages (for performance)
        let recentHistory = Array(history.suffix(10))
        
        for chatMessage in recentHistory {
            let role = chatMessage.isFromUser ? "User" : "Assistant"
            contextString += "\(role): \(chatMessage.text)\n"
        }
        
        return """
        You are an AI podcast expert assistant. Respond taking into account the previous conversation history.
        
        Previous conversation:
        \(contextString)
        
        New message: \"\(message)\"
        
        Please:
        - Provide consistent responses considering the previous conversation
        - Give expert advice on podcast topics
        - Offer creative and inspiring suggestions
        - Respond in English
        - Use a friendly and helpful tone
        - Do NOT use ** or any markdown formatting for bold or emphasis
        
        Keep your response to a maximum of 120 words.
        """
    }
} 