//
//  NetworkConstants.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

struct NetworkConstants {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = dict["API_KEY"] as? String else {
            fatalError("API_KEY bulunamadı. Lütfen GenerativeAI-Info.plist dosyasını kontrol edin.")
        }
        return apiKey
    }
    
    static let baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
}
