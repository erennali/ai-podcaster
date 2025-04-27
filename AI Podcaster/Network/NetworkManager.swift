//
//  NetworkManager.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import Foundation
import Alamofire

enum HTTPMethod: String {
    case GET
    case POST
}

protocol NetworkManagerProtocol {
    func request<T: Codable>(
        url: URL,
        method: HTTPMethod,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
}

final class NetworkManager: NetworkManagerProtocol {
    func request<T: Codable>(
        url: URL,
        method: HTTPMethod,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let afMethod = Alamofire.HTTPMethod(rawValue: method.rawValue)
        
        AF.request(url, method: afMethod).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decodedData):
                completion(.success(decodedData))
            case .failure(let error):
                if let afError = error.asAFError {
                    switch afError {
                    case .responseValidationFailed(let reason):
                        if case .unacceptableStatusCode(let statusCode) = reason {
                            completion(.failure(.requestFailedWith(statusCode)))
                        } else {
                            completion(.failure(.invalidResponse))
                        }
                    default:
                        completion(.failure(.customError(error)))
                    }
                } else {
                    completion(.failure(.decodingError))
                }
            }
        }
    }
}
    
    

