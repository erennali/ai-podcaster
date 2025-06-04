//
//  GoogleAIService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation
import GoogleGenerativeAI

class GoogleAIService {
    static let shared = GoogleAIService()
    private let model: GenerativeModel
    
    private init() {
        let config = GenerationConfig(
            temperature: 0.7,
            topP: 0.8,
            topK: 40,
            maxOutputTokens: 2048,
            stopSequences: []
        )
        
        self.model = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: NetworkConstants.apiKey,
            generationConfig: config
        )
    }
    
    func generateAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let response = try await model.generateContent(prompt)
                if let text = response.text {
                    DispatchQueue.main.async {
                        completion(.success(text))
                    }
                } else {
                    completion(.failure(NSError(domain: "GoogleAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Yanıt metni alınamadı"])))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchDailyMotivation(completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = """
        Günlük motivasyon mesajı oluştur: 50-60 kelime arasında, kişisel gelişim odaklı, pozitif ve ilham verici bir söz yaz. Başarı, hedefler, öz güven, azim, değişim, cesaret gibi temalardan birini seç. Günlük hayatta uygulanabilir, duygusal bağ kuran, akılda kalıcı bir mesaj olsun. Sadece motivasyon metnini döndür, ek açıklama yapma. Her çağrıda benzersiz içerik üret.
            - \(SceneDelegate.appLanguageName) dilinde yaz.
        """
        generateAIResponse(prompt: prompt, completion: completion)
    }
}
