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
}
