import Foundation

// MARK: - Protocol
protocol GuestUsageServiceProtocol {
    var remainingGuestMessages: Int { get }
    func useGuestMessage() -> Bool
    func resetGuestUsage()
    func isGuestMessageAvailable() -> Bool
}

// MARK: - Implementation
final class GuestUsageService: GuestUsageServiceProtocol {
    // MARK: - Singleton
    static let shared = GuestUsageService()
    
    // MARK: - Constants
    private let maxGuestMessages = 3
    private let guestMessagesKey = "guestRemainingMessages"
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    
    var remainingGuestMessages: Int {
        return userDefaults.integer(forKey: guestMessagesKey)
    }
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // Initialize remaining messages if not set yet
        if userDefaults.object(forKey: guestMessagesKey) == nil {
            userDefaults.set(maxGuestMessages, forKey: guestMessagesKey)
        }
    }
    
    // MARK: - Public Methods
    func useGuestMessage() -> Bool {
        let currentCount = remainingGuestMessages
        
        guard currentCount > 0 else {
            return false
        }
        
        userDefaults.set(currentCount - 1, forKey: guestMessagesKey)
        return true
    }
    
    func resetGuestUsage() {
        userDefaults.set(maxGuestMessages, forKey: guestMessagesKey)
    }
    
    func isGuestMessageAvailable() -> Bool {
        return remainingGuestMessages > 0
    }
} 