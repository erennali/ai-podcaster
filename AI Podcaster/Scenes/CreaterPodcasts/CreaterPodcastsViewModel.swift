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
}

final class CreaterPodcastsViewModel: NSObject {
    // MARK: - Properties
    private let googleAIService: GoogleAIService
    let speechService: AVSpeechService
    private var currentText: String?
    private let db = Firestore.firestore()
    private let subscriptionService: UserSubscriptionServiceProtocol
    
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
         subscriptionService: UserSubscriptionServiceProtocol = UserSubscriptionService.shared) {
        self.googleAIService = googleAIService
        self.speechService = speechService
        self.subscriptionService = subscriptionService
        super.init()
    }
    
    // MARK: - Public Methods
    func generatePodcast(prompt: String, duration: Int, style: String, language: String) {
        
        if !SceneDelegate.loginUser {
            delegate?.didShowAlert(message: "You must be logged in to use this feature!")
            return
        }
        
        guard !prompt.isEmpty else {
            delegate?.didShowAlert(message: "Please enter a question or request")
            return
        }
        
        // Check subscription status before proceeding
        subscriptionService.isFreePremiumFeatureAccessible { [weak self] canAccess, message in
            guard let self = self else { return }
            
            if let message = message {
                self.delegate?.didShowAlert(message: message)
            }
            
            if !canAccess {
                self.delegate?.didShowError("Your 7-day free trial has expired. Please upgrade to continue using this feature.")
                return
            }
            
            // Continue with original implementation if user has access
            self.delegate?.didUpdateUIState(isLoading: true)
            
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
            self.googleAIService.generateAIResponse(prompt: podcastPrompt) { [weak self] result in
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
    }
    
    func savePodcast(id:UUID,title: String, style: String, language: String, duration: Int) {
        guard let currentText = currentText,
              let userId = Auth.auth().currentUser?.uid else {
            delegate?.didShowError("Failed to save podcast")
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
