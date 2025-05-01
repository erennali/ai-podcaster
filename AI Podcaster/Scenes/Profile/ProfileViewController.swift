//
//  ProfileViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
                    if let data = snapshot?.data() {
                        print("Kullanıcı verisi: \(data)")
                        self.nameLabel.text = data["name"] as? String
                    }
                }
            }
        configureView()
    }
    
    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Exit", for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .systemFont(ofSize: 20)
        return label
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
        view.backgroundColor = .systemBackground
       
       addViews()
       configureLayout()
    
    }
    
    func addViews() {
        view.addSubview(exitButton)
        view.addSubview(nameLabel)
    }
    
    func configureLayout() {
        exitButton.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        nameLabel.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
    }
}

