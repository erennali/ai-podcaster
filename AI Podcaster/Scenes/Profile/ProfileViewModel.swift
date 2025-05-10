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
    
    // MARK: - Public Methods
    func loadUserData() {
        if let userData = firebaseService.getUserData() {
            let name = userData["name"] as? String ?? ""
            let email = userData["email"] as? String ?? ""
            let podcastCount = userData["podcastCount"] as? Int ?? 0
            
            delegate?.userDataDidUpdate(name: name, email: email, podcastCount: podcastCount)
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
