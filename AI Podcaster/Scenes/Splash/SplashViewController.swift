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
    
    private let viewModel = SplashViewModel()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background3")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
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
        label.textColor = .white // Changed to white for better visibility on background
        label.font = .preferredFont(forTextStyle: .extraLargeTitle)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupViewModel()
        viewModel.loadInitialData()
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
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
        view.addSubview(backgroundImageView)
        view.addSubview(iconImage)
        view.addSubview(podcastLabel)
    }
    
    func configureLayout() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
            sceneDelegate.changeRootViewController(tabBarController)
        }
    }
}

// MARK: - SplashViewModelDelegate
extension SplashViewController: SplashViewModelDelegate {
    func didFinishLoading() {
        navigateToTabBar()
    }
    
    func didFailLoading(with error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


