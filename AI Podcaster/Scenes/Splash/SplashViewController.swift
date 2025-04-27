//
//  SplashViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit

class SplashViewController: UIViewController {

    
    // MARK: - Properties
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "music.quarternote.3")
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
        navigateToTabBar()
        
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
        
        
        NSLayoutConstraint.activate([
            iconImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 200),
            iconImage.heightAnchor.constraint(equalToConstant: 200),
            
            podcastLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 8),
            podcastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func navigateToTabBar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            let tabBarController = TabBarController()
            sceneDelegate.window?.rootViewController = tabBarController
        }
    }
        
    
    
    
}

