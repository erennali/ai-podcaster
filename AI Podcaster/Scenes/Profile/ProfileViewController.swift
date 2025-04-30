//
//  ProfileViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Exit", for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()


    
    // MARK: - Actions
    @objc private func logoutButtonTapped() {
            let alert = UIAlertController(
                title: "Çıkış Yap",
                message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
            alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
                // Firebase'den çıkış yap
                do {
                    try Auth.auth().signOut()
                    
                    // UserDefaults'u temizle
                    UserDefaults.standard.removeObject(forKey: "userData")
                    SceneDelegate.loginUser = false
                    let splashVC = SplashViewController()
                                
                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                    sceneDelegate.changeRootViewController(splashVC)
                                }

                } catch {
                    print("Çıkış yapılırken hata oluştu: \(error.localizedDescription)")
                }
            })
            
            present(alert, animated: true)
        }

}
extension ProfileViewController {
    // MARK: - UI Setup
     func configureView() {
        view.backgroundColor = .white
       
       addViews()
       configureLayout()
    
    }
    
    func addViews() {
        view.addSubview(exitButton)
    }
    
    func configureLayout() {
        exitButton.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}

