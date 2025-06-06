import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

protocol CreaterPodcastsViewModelDelegate: AnyObject {
    func didUpdateResponse(_ response: String)
    func didUpdatePlaybackState(isPlaying: Bool)
    func didShowError(_ error: String)
    func didUpdateUIState(isLoading: Bool)
    func didShowAlert(message: String)
    func didSavePodcastSuccessfully()
    func scrollToOutputContainer()
}

final class CreaterPodcastsViewModel: NSObject {
    // MARK: - Properties
    private let userDefaultsKey = "hasShownFirstTimeAlert"
    private let googleAIService: GoogleAIService
    let speechService: AVSpeechService
    private var currentText: String?
    private let db = Firestore.firestore()
    private let subscriptionService: UserSubscriptionServiceProtocol
    private let guestUsageService: GuestUsageServiceProtocol
    
    weak var delegate: CreaterPodcastsViewModelDelegate?
    
    var isPlaying: Bool = false {
        didSet {
            delegate?.didUpdatePlaybackState(isPlaying: isPlaying)
        }
    }
    
    let languages = [
        ("Türkçe", "tr-TR"),
        ("English (US)", "en-US"),
        ("English (UK)", "en-GB"),
        ("Español", "es-ES"),
        ("Français", "fr-FR"),
        ("Deutsch", "de-DE"),
        ("Italiano", "it-IT"),
        ("Português", "pt-BR"),
        ("Русский", "ru-RU"),
        ("日本語", "ja-JP"),
        ("한국어", "ko-KR"),
        ("中文", "zh-CN"),
        ("العربية", "ar-SA")
    ]
    
    // MARK: - Initialization
    init(googleAIService: GoogleAIService = .shared,
         speechService: AVSpeechService = .shared,
         subscriptionService: UserSubscriptionServiceProtocol = UserSubscriptionService.shared,
         guestUsageService: GuestUsageServiceProtocol = GuestUsageService.shared) {
        self.googleAIService = googleAIService
        self.speechService = speechService
        self.subscriptionService = subscriptionService
        self.guestUsageService = guestUsageService
        super.init()
    }
    
    // MARK: - Public Methods
    func shouldShowFirstTimeAlert() -> Bool {
            let hasShown = UserDefaults.standard.bool(forKey: userDefaultsKey)
            if !hasShown {
                UserDefaults.standard.set(true, forKey: userDefaultsKey)
            }
            return !hasShown
        }
    
    func generatePodcast(prompt: String, duration: Int, style: String, language: String) {
        guard !prompt.isEmpty else {
            delegate?.didShowAlert(message: NSLocalizedString("enterQuestion", comment: ""))
            return
        }
        
        // Check if user is logged in
        if !SceneDelegate.loginUser {
            // Guest user flow
            if !guestUsageService.isGuestMessageAvailable() {
                // No more free messages available
                delegate?.didShowAlert(message: NSLocalizedString("guestLimitReached", comment: ""))
                return
            }
            
            // Use a free message
            _ = guestUsageService.useGuestMessage()
            
            // If this is the last message, inform the user
            if guestUsageService.remainingGuestMessages == 0 {
                delegate?.didShowAlert(message: NSLocalizedString("lastFreeMessage", comment: ""))
            } else if guestUsageService.remainingGuestMessages == 1 {
                delegate?.didShowAlert(message: NSLocalizedString("oneMessageLeft", comment: ""))
            }
            
            // Continue with podcast generation for guest
            processPodcastGeneration(prompt: prompt, duration: duration, style: style, language: language)
            return
        }
        
        // Logged-in user flow - check subscription status
        subscriptionService.isFreePremiumFeatureAccessible { [weak self] canAccess, message in
            guard let self = self else { return }
            
            if let message = message {
                self.delegate?.didShowAlert(message: message)
            }
            
            if !canAccess {
                self.delegate?.didShowError(NSLocalizedString("trialExpired", comment: ""))
                return
            }
            
            // Continue with podcast generation for subscribed user
            self.processPodcastGeneration(prompt: prompt, duration: duration, style: style, language: language)
        }
    }
    
    // Helper method to avoid code duplication
    private func processPodcastGeneration(prompt: String, duration: Int, style: String, language: String) {
        delegate?.didUpdateUIState(isLoading: true)
        delegate?.scrollToOutputContainer()
        
        let podcastPrompt = """
        Sen profesyonel bir podcast içerik yazarısın. Bana aşağıdaki kriterlere uygun bir podcast senaryosu hazırla:

        KONU: \(prompt)
        SÜRE: \(duration) dakika (yaklaşık \(duration * 350) kelime)
        ÜSLUp: \(style)
        DİL: \(language)

        YAZIM KURALLARI:
        - Sadece TEK KİŞİLİK anlatım için yaz (monolog formatında)
        - Sadece paragraf halinde yaz, başlık, liste veya ek açıklama ekleme
        - Doğrudan içeriği yaz, giriş metni veya açıklama yapma
        - Akıcı, doğal konuşma dili kullan
        - Dinleyiciye hitap eden, kişisel bir ton benimse
        - Geçişleri ve bağlantıları sorunsuz yap
        - Belirtilen süreye uygun kelime sayısında tut

        İçeriği hemen başlat: 
        """
        googleAIService.generateAIResponse(prompt: podcastPrompt) { [weak self] result in
            DispatchQueue.main.async {
                self?.delegate?.didUpdateUIState(isLoading: false)
                
                switch result {
                case .success(let response):
                    self?.currentText = response
                    self?.delegate?.didUpdateResponse(response)
                case .failure(let error):
                    self?.delegate?.didShowError(error.localizedDescription)
                }
            }
        }
    }
    
    func savePodcast(id:UUID,title: String, style: String, language: String, duration: Int) {
        guard let currentText = currentText else {
            delegate?.didShowError(NSLocalizedString("failedSavePodcast", comment: ""))
            return
        }
        
        // Check if user is logged in
        if !SceneDelegate.loginUser {
            delegate?.didShowAlert(message: NSLocalizedString("createAccountForMore", comment: ""))
            return
        }
        
        // User is logged in, proceed with saving
        guard let userId = Auth.auth().currentUser?.uid else {
            delegate?.didShowError(NSLocalizedString("failedSavePodcast", comment: ""))
            return
        }
        
        let podcastData: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "content": currentText,
            "minutes": duration,
            "style": style,
            "language": language,
            "createdAt": FieldValue.serverTimestamp(),
            "userId": userId
        ]
        
        db.collection("users").document(userId).collection("podcasts").addDocument(data: podcastData) { [weak self] error in
            if let error = error {
                self?.delegate?.didShowError(error.localizedDescription)
            } else {
                self?.delegate?.didSavePodcastSuccessfully()
            }
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            pauseSpeech()
        } else {
            playSpeech()
        }
    }
    
    func getLanguageName(at index: Int) -> String {
        return languages[index].0
    }
    
    func getLanguageCode(at index: Int) -> String {
        return languages[index].1
    }
    
    // MARK: - Private Methods
    private func playSpeech() {
        guard let text = currentText else { return }
        if speechService.synthesizer.isPaused {
            speechService.resume()
        } else {
            speechService.speak(text: text)
        }
        isPlaying = true
    }
    
    private func pauseSpeech() {
        speechService.pause()
        isPlaying = false
    }
}
