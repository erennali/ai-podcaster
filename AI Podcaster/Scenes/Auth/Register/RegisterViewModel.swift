import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol RegisterViewModelDelegate: AnyObject {
    func registrationDidStart()
    func registrationDidComplete()
    func registrationDidFail(with error: String)
}

class RegisterViewModel {
    weak var delegate: RegisterViewModelDelegate?
    
    private(set) var email: String = ""
    private(set) var password: String = ""
    private(set) var name: String = ""
    private(set) var isLoading: Bool = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func updateEmail(_ email: String) {
        self.email = email
    }
    
    func updatePassword(_ password: String) {
        self.password = password
    }
    
    func updateName(_ name: String) {
        self.name = name
    }
    
    func register() {
        guard validateForm() else { return }
        
        isLoading = true
        delegate?.registrationDidStart()
        
        // Firebase Authentication ile kullanıcı oluşturma
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.delegate?.registrationDidFail(with: error.localizedDescription)
                return
            }
            
            guard let userId = result?.user.uid else {
                self.isLoading = false
                self.delegate?.registrationDidFail(with: NSLocalizedString("failCreateUser", comment: ""))
                return
            }
            
            // Firestore'a kullanıcı bilgilerini kaydetme
            let userData = AppUser(
                id: userId,
                email: self.email,
                name: self.name,
                profileImageUrl: nil,
                subscriptionType: .free,
                isPremium: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            do {
                try self.db.collection("users").document(userId).setData(from: userData)
                self.isLoading = false
                self.delegate?.registrationDidComplete()
                SceneDelegate.loginUser = true
                let splashVC = SplashViewController()
                            
                            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                sceneDelegate.changeRootViewController(splashVC)
                            }

            } catch {
                self.isLoading = false
                self.delegate?.registrationDidFail(with: "\(NSLocalizedString("failSaveUser", comment: "")): \(error.localizedDescription)")
            }
        }
    }
    
    private func validateForm() -> Bool {
        if email.isEmpty {
            delegate?.registrationDidFail(with: NSLocalizedString("notEmptyEmail", comment: ""))
            return false
        }
        
        if !email.contains("@") {
            delegate?.registrationDidFail(with: NSLocalizedString("pleaseRealEmail", comment: ""))
            return false
        }
        
        if password.isEmpty {
            delegate?.registrationDidFail(with: NSLocalizedString("notEmptyPassword", comment: ""))
            return false
        }
        
        if password.count < 6 {
            delegate?.registrationDidFail(with: NSLocalizedString("passwordMinLength", comment: ""))
            return false
        }
        
        if name.isEmpty {
            delegate?.registrationDidFail(with: NSLocalizedString("notEmptyName", comment: ""))
            return false
        }
        
        return true
    }
} 
