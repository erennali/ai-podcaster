//
//  LoginViewModel.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 30.04.2025.
//

import Foundation
import FirebaseAuth

protocol LoginViewModelDelegate: AnyObject {
    func didLoginSuccessfully()
    func didFailToLogin(with error: String)
    func didSendPasswordReset()
    func didFailToSendPasswordReset(with error: String)
}

class LoginViewModel {
    
    weak var delegate: LoginViewModelDelegate?
    
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            delegate?.didFailToLogin(with: "Please enter your email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.delegate?.didFailToLogin(with: error.localizedDescription)
                return
            }
            
            // User is signed in
            SceneDelegate.loginUser = true
            self?.delegate?.didLoginSuccessfully()
        }
    }
    
    func resetPassword(email: String) {
        guard !email.isEmpty else {
            delegate?.didFailToSendPasswordReset(with: "Please enter your email address.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailToSendPasswordReset(with: error.localizedDescription)
                return
            }
            
            self?.delegate?.didSendPasswordReset()
        }
    }
} 