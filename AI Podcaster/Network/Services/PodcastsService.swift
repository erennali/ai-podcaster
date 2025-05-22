//
//  PodcastsService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 15.05.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol PodcastsServiceProtocol {
    func fetchPodcasts(completion: @escaping (Result<[Podcast], Error>) -> Void)
    func savePodcast(_ podcast: Podcast, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePodcast(_ podcastId: String, completion: @escaping (Result<Void, Error>) -> Void)
}


    
final class PodcastsService: PodcastsServiceProtocol {
   
    
    private let firestore = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid
    
   
    
}

extension PodcastsService {
    func savePodcast(_ podcast: Podcast, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "User not logged in", code: 401, userInfo: nil)))
            return
        }
        
        do {
            try firestore.collection("users").document(userId).collection("podcasts").document(podcast.id).setData(from: podcast) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deletePodcast(_ podcastId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "User not logged in", code: 401, userInfo: nil)))
            return
        }
        
        // Doğrudan podcast ID'si ile belgeyi bul ve sil
        firestore.collection("users").document(userId).collection("podcasts").whereField("id", isEqualTo: podcastId).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(.success(()))
                return
            }
            
            // Belgeyi sil
            self.firestore.collection("users").document(userId).collection("podcasts").document(document.documentID).delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    
    func fetchPodcasts(completion: @escaping (Result<[Podcast], Error>) -> Void) {
        guard let userId = userId else {
            print("Error: User not logged in")
            completion(.failure(NSError(domain: "User not logged in", code: 401, userInfo: nil)))
            return
        }
        
        print("Fetching podcasts for user: \(userId)")
        firestore.collection("users").document(userId).collection("podcasts").getDocuments { snapshot, error in
            if let error = error {
                print("Firebase error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                completion(.success([]))
                return
            }
            
            print("Found \(documents.count) documents")
            
            do {
                let podcasts = try documents.compactMap { document -> Podcast? in
                    do {
                        // Ham veriyi yazdır
                        print("Raw data for document \(document.documentID):")
                        print(document.data())
                        
                        let podcast = try document.data(as: Podcast.self)
                        print("Successfully decoded podcast: \(podcast.id)")
                        return podcast
                    } catch {
                        print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Missing key: \(key.stringValue)")
                                print("Context: \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                print("Type mismatch: expected \(type)")
                                print("Context: \(context.debugDescription)")
                            case .valueNotFound(let type, let context):
                                print("Value not found: expected \(type)")
                                print("Context: \(context.debugDescription)")
                            default:
                                print("Other decoding error: \(decodingError)")
                            }
                        }
                        return nil
                    }
                }
                print("Successfully decoded \(podcasts.count) podcasts")
                completion(.success(podcasts))
            } catch {
                print("Error decoding podcasts: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
