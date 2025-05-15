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
    init(googleAIService: GoogleAIService = .shared, speechService: AVSpeechService = .shared) {
        self.googleAIService = googleAIService
        self.speechService = speechService
        super.init()
    }
    
    // MARK: - Public Methods
    func generatePodcast(prompt: String, duration: Int, style: String, language: String) {
        guard !prompt.isEmpty else {
            delegate?.didShowAlert(message: "Please enter a question or request")
            return
        }
        
        if !SceneDelegate.loginUser {
            delegate?.didShowAlert(message: "You must be logged in to use this feature!")
            return
        }
        
        delegate?.didUpdateUIState(isLoading: true)
        
        let podcastPrompt = "Create a podcast content that I can convert into an audio file by typing it into the text to speech AI tool in the subject \(prompt), with a reading time \(duration) minutes, with a style \(style). Write the podcast content directly and only in paragraphs, don't write anything else. Only 1 person will voice the podcast, write accordingly. Answer in \(language)."
        
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
