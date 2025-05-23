//
//  ChatViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import Foundation

// MARK: - Chat ViewModel Delegate Protocol
protocol ChatViewModelDelegate: AnyObject {
    func didUpdateMessages()
    func didUpdateChatState(_ state: ChatState)
    func didFailWithError(_ error: String)
    func didReceiveAIResponse()
}

// MARK: - Chat ViewModel Protocol
protocol ChatViewModelProtocol: AnyObject {
    var delegate: ChatViewModelDelegate? { get set }
    var messages: [ChatMessage] { get }
    var currentState: ChatState { get }
    
    func sendMessage(_ text: String)
    func loadInitialMessages()
    func clearChat()
}

// MARK: - Chat ViewModel Implementation
final class ChatViewModel: ChatViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ChatViewModelDelegate?
    private let chatService: ChatServiceProtocol
    
    private(set) var messages: [ChatMessage] = []
    private(set) var currentState: ChatState = .idle
    
    // MARK: - Initialization
    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
    }
    
    // MARK: - Public Methods
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard currentState != .loading else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: text, isFromUser: true)
        addMessage(userMessage)
        
        // Update state to loading
        updateState(.loading)
        
        // Send message to AI service
        chatService.sendMessageWithHistory(text, history: messages) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleAIResponse(result)
            }
        }
    }
    
    func loadInitialMessages() {
        let welcomeMessage = ChatMessage(
            text: "Hello! I'm your AI Podcast assistant. I can help you with podcast topics, content creation, storytelling, and audio content. How can I assist you?",
            isFromUser: false
        )
        addMessage(welcomeMessage)
    }
    
    func clearChat() {
        messages.removeAll()
        updateState(.idle)
        delegate?.didUpdateMessages()
    }
}

// MARK: - Private Methods
private extension ChatViewModel {
    
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
        delegate?.didUpdateMessages()
    }
    
    func updateState(_ state: ChatState) {
        currentState = state
        delegate?.didUpdateChatState(state)
    }
    
    func handleAIResponse(_ result: Result<String, NetworkError>) {
        updateState(.idle)
        
        switch result {
        case .success(let response):
            let cleanedResponse = response.replacingOccurrences(of: "**", with: "")
            let aiMessage = ChatMessage(text: cleanedResponse, isFromUser: false)
            addMessage(aiMessage)
            delegate?.didReceiveAIResponse()
            
        case .failure(let error):
            let errorMessage = ChatMessage(
                text: "I'm sorry, an error occurred. Please try again.",
                isFromUser: false
            )
            addMessage(errorMessage)
            delegate?.didFailWithError(error.localizedDescription)
        }
    }
} 