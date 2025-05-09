//
//  SplashViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit


class SplashViewController: UIViewController {

    
    // MARK: - Properties
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.quarternote.3")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let podcastLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Podcaster"
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .extraLargeTitle)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        Task {
            await FirebaseService.shared.fetchUserData()
            navigateToTabBar()
        }
    }
    
}

// MARK: - Private Methods

private extension SplashViewController {
    
    func configureView() {
        view.backgroundColor = .systemBackground
        addViews()
        configureLayout()
    }
    
    func addViews() {
        view.addSubview(iconImage)
        view.addSubview(podcastLabel)
    }
    
    func configureLayout() {
        iconImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50) // İkon biraz yukarıda olsun
            make.width.height.equalTo(100) // İkon boyutu
        }
        
        podcastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImage.snp.bottom).offset(20) // İkonun altına biraz boşluk bırak
        }
    }
    
    func navigateToTabBar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            let tabBarController = TabBarController()
            sceneDelegate.window?.rootViewController = tabBarController
        }
    }
        
    
    
    
}

#Preview {
    SplashViewController()
}

