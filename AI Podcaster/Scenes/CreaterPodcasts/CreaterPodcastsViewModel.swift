import Foundation
import AVFoundation

protocol CreaterPodcastsViewModelDelegate: AnyObject {
    func didUpdateResponse(_ response: String)
    func didUpdatePlaybackState(isPlaying: Bool)
    func didShowError(_ error: String)
}

final class CreaterPodcastsViewModel: NSObject {
    // MARK: - Properties
    private let googleAIService: GoogleAIService
    let speechService: AVSpeechService
    private var currentText: String?
    
    weak var delegate: CreaterPodcastsViewModelDelegate?
    
    var isPlaying: Bool = false {
        didSet {
            delegate?.didUpdatePlaybackState(isPlaying: isPlaying)
        }
    }
    
    // MARK: - Initialization
    init(googleAIService: GoogleAIService = .shared, speechService: AVSpeechService = .shared) {
        self.googleAIService = googleAIService
        self.speechService = speechService
        super.init()
    }
    
    // MARK: - Public Methods
    func generatePodcast(prompt: String, duration: Int, style: String) {
        let podcastPrompt = "Create a podcast content that I can convert into an audio file by typing it into the text to speech AI tool in the subject \(prompt), with a reading time \(duration) minutes, with a style \(style). Write the podcast content directly and only in paragraphs, don't write anything else. Only 1 person will voice the podcast, write accordingly"
        
        googleAIService.generateAIResponse(prompt: podcastPrompt) { [weak self] result in
            DispatchQueue.main.async {
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
    
    func togglePlayback() {
        if isPlaying {
            pauseSpeech()
        } else {
            playSpeech()
        }
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
