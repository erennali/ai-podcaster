import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ProfileViewModelDelegate: AnyObject {
    func userDataDidUpdate(name: String, email: String, podcastCount: Int)
    func signOutDidComplete()
    func signOutDidFail(with error: Error)
}

class ProfileViewModel {
    // MARK: - Properties
    weak var delegate: ProfileViewModelDelegate?
    private let firebaseService = FirebaseService.shared
    private let firestore = Firestore.firestore()
    private let iapService = IAPService.shared
    
    // MARK: - Public Methods
    func loadUserData() {
        Task {
            // Firebase'den kullanıcı verilerini güncel olarak al
            await firebaseService.fetchUserData()
            
            if let userData = firebaseService.getUserData() {
                let name = userData["name"] as? String ?? ""
                let email = userData["email"] as? String ?? ""
                
                // Premium durumunu RevenueCat'ten kontrol et
                let isPremiumFromRevenueCat = iapService.isPremiumUser()
                
                // Firebase ile RevenueCat arasında uyumsuzluk varsa güncelle
                let isPremiumFromFirebase = userData["isPremium"] as? Bool ?? false
                if isPremiumFromRevenueCat != isPremiumFromFirebase {
                    iapService.updatePremiumStatusInFirebase()
                }
                
                fetchPodcastCount(name: name, email: email)
            }
        }
    }
    
    private func fetchPodcastCount(name: String, email: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            delegate?.userDataDidUpdate(name: name, email: email, podcastCount: 0)
            return
        }
        
        firestore.collection("users").document(userId).collection("podcasts").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching podcasts: \(error.localizedDescription)")
                self.delegate?.userDataDidUpdate(name: name, email: email, podcastCount: 0)
                return
            }
            
            let podcastCount = snapshot?.documents.count ?? 0
            self.delegate?.userDataDidUpdate(name: name, email: email, podcastCount: podcastCount)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userData")
            SceneDelegate.loginUser = false
            delegate?.signOutDidComplete()
        } catch {
            delegate?.signOutDidFail(with: error)
        }
    }
} 
