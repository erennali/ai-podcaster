//
//  NetworkError.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidRequest
    case invalidData
    case invalidResponse
    case requestFailedWith(Int)
    case decodingError
    case customError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Invalid Request"
        case .invalidData:
            return "Invalid Data"
        case .invalidResponse:
            return "Invalid Response"
        case .decodingError:
            return "Decoding Error"
        case .requestFailedWith(let statusCode):
            return "Request Failed with status code: \(statusCode)"
        case .customError(let error):
            return "Custom Error: \(error.localizedDescription)"
        }
    }
}
