//
//  ProfileViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import FirebaseAuth
import SnapKit

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    
    // MARK: - UI Components
    private let betterAudioExperienceButton: UIButton = {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = NSLocalizedString("openBetterAudioExperience", comment: "")
        configuration.baseBackgroundColor = UIColor(named: "anaTemaRenk") // Theme color
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.image = UIImage(systemName: "speaker.wave.2.circle") // Minimal icon
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        button.configuration = configuration
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.08
        button.layer.shadowRadius = 3
        button.addTarget(self, action: #selector(openBetterAudioExperience), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor(named: "anaTemaRenk")
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var premiumBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "anaTemaRenk")
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        
        let label = UILabel()
        label.text = "PRO"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        }
        
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var podcastsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var podcastsCountView: StatView = {
        let view = StatView(title: NSLocalizedString("podcasts", comment: ""), value: "0")
        return view
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIButton.Configuration.filled()
        button.configuration = configuration
        button.setTitle(NSLocalizedString("settings", comment: ""), for: .normal)
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIButton.Configuration.bordered()
        button.configuration = configuration
        button.setTitle(NSLocalizedString("signOut", comment: ""), for: .normal)
        button.setImage(UIImage(systemName: "arrow.right.circle"), for: .normal)
        button.tintColor = .systemRed
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        configureView()
        
        // Abonelik durum değişikliklerini dinle
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusChanged), name: .subscriptionStatusChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadUserData()
        updatePremiumStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
        viewModel.loadUserData()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        
        addViews()
        configureLayout()
    }
    
    private func addViews() {
        view.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(premiumBadge)
        containerView.addSubview(nameLabel)
        containerView.addSubview(emailLabel)
        
        view.addSubview(podcastsContainerView)
        podcastsContainerView.addSubview(podcastsCountView)
        
        view.addSubview(settingsButton)
        view.addSubview(exitButton)
        view.addSubview(betterAudioExperienceButton)
    }
    
    private func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        premiumBadge.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView.snp.bottom).offset(-5)
            make.trailing.equalTo(profileImageView.snp.trailing).offset(5)
            make.width.height.equalTo(42)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(containerView).offset(-20)
        }
        
        podcastsContainerView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(95)
        }
        
        podcastsCountView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(exitButton.snp.top).offset(-12)
            make.height.equalTo(50)
        }
        
        exitButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
        betterAudioExperienceButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(podcastsContainerView.snp.bottom).offset(16)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Premium Status
    private func updatePremiumStatus() {
        let isPremium = IAPService.shared.isPremiumUser()
        premiumBadge.isHidden = !isPremium
    }
    
    // MARK: - Actions
    @objc private func openBetterAudioExperience() {
            let alert = UIAlertController(
                title: NSLocalizedString("betterAudioExperienceTitle", comment: ""),
                message: NSLocalizedString("betterAudioExperienceMessage", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("betterAudioExperienceButton", comment: ""), style: .default))
            present(alert, animated: true)
        }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("signOut", comment: ""),
            message: NSLocalizedString("areYouSureSignOut", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("signOut", comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel.signOut()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func subscriptionStatusChanged() {
        updatePremiumStatus()
    }
}

// MARK: - ProfileViewModelDelegate
extension ProfileViewController: ProfileViewModelDelegate {
    func userDataDidUpdate(name: String, email: String, podcastCount: Int) {
        nameLabel.text = name
        emailLabel.text = email
        podcastsCountView.updateValue("\(podcastCount)")
        updatePremiumStatus()
    }
    
    func signOutDidComplete() {
        let splashVC = SplashViewController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(splashVC)
        }
    }
    
    func signOutDidFail(with error: Error) {
        print("Error signing out: \(error.localizedDescription)")
    }
}

