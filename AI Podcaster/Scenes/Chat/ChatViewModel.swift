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
    private let subscriptionService: UserSubscriptionServiceProtocol
    private let guestUsageService: GuestUsageServiceProtocol
    
    private(set) var messages: [ChatMessage] = []
    private(set) var currentState: ChatState = .idle
    
    // MARK: - Initialization
    init(chatService: ChatServiceProtocol = ChatService(),
         subscriptionService: UserSubscriptionServiceProtocol = UserSubscriptionService.shared,
         guestUsageService: GuestUsageServiceProtocol = GuestUsageService.shared) {
        self.chatService = chatService
        self.subscriptionService = subscriptionService
        self.guestUsageService = guestUsageService
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
        
        // Check if user is logged in
        if !SceneDelegate.loginUser {
            // Guest user flow
            if !guestUsageService.isGuestMessageAvailable() {
                // No more free messages available
                updateState(.idle)
                let messageText = NSLocalizedString("guestLimitReached", comment: "")
                let limitMessage = ChatMessage(text: messageText, isFromUser: false)
                addMessage(limitMessage)
                delegate?.didFailWithError(NSLocalizedString("createAccountForMore", comment: ""))
                return
            }
            
            // Use a free message
            _ = guestUsageService.useGuestMessage()
            
            // If this is the last message, inform the user
            if guestUsageService.remainingGuestMessages == 0 {
                let remainingText = NSLocalizedString("lastFreeMessage", comment: "")
                let infoMessage = ChatMessage(text: remainingText, isFromUser: false)
                addMessage(infoMessage)
            } else if guestUsageService.remainingGuestMessages == 1 {
                let remainingText = NSLocalizedString("oneMessageLeft", comment: "")
                let infoMessage = ChatMessage(text: remainingText, isFromUser: false)
                addMessage(infoMessage)
            }
            
            // Process the message for guest user
            chatService.sendMessageWithHistory(text, history: messages) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleAIResponse(result)
                }
            }
            return
        }
        
        // Logged-in user flow - check subscription status
        subscriptionService.isFreePremiumFeatureAccessible { [weak self] canAccess, message in
            guard let self = self else { return }
            
            if let message = message {
                // If there's a message about trial days left, we can show it as a message
                if message.contains("day") && message.contains("trial") {
                    let infoMessage = ChatMessage(text: message, isFromUser: false)
                    self.addMessage(infoMessage)
                }
            }
            
            if !canAccess {
                // Trial expired, show message and stop
                self.updateState(.idle)
                let errorMessage = ChatMessage(
                    text: NSLocalizedString("trialExpired", comment: ""),
                    isFromUser: false
                )
                self.addMessage(errorMessage)
                self.delegate?.didFailWithError(NSLocalizedString("freeTrialExpired", comment: ""))
                return
            }
            
            // Continue with original implementation for logged-in users
            self.chatService.sendMessageWithHistory(text, history: self.messages) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleAIResponse(result)
                }
            }
        }
    }
    
    func loadInitialMessages() {
        let welcomeMessage = ChatMessage(
            text: NSLocalizedString("welcomeAIResponse", comment: ""),
            isFromUser: false
        )
        addMessage(welcomeMessage)
        
        // For guest users, show remaining message count
        if !SceneDelegate.loginUser && guestUsageService.remainingGuestMessages > 0 {
            let remainingFormat = NSLocalizedString("remainingFreeMessages", comment: "")
            let remainingText = String(format: remainingFormat, guestUsageService.remainingGuestMessages)
            let infoMessage = ChatMessage(text: remainingText, isFromUser: false)
            addMessage(infoMessage)
        }
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
                text: NSLocalizedString("tryAgain", comment: ""),
                isFromUser: false
            )
            addMessage(errorMessage)
            delegate?.didFailWithError(error.localizedDescription)
        }
    }
}
