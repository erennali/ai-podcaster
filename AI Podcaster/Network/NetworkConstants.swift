//
//  NetworkConstants.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

struct NetworkConstants {
    static var apiKey: String {
        guard let apiKey = EnvironmentManager.shared.getAPIKey() else {
            fatalError("API_KEY bulunamadı. Lütfen .env dosyasını kontrol edin.")
        }
        return apiKey
    }
    static var elevenLabsApiKey: String {
        guard let elevenLabsApiKey = EnvironmentManager.shared.getElevenlabsAPIKey() else {
            fatalError("ELEVEN_LABS_API_KEY bulunamadı. Lütfen .env dosyasını kontrol edin.")
        }
        
        return elevenLabsApiKey
    }
    
    static let baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
}
