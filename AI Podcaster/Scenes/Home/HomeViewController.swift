//
//  HomeViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit
import SnapKit


class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
    // MARK: - UI Components
    private let welcomeTitle: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 24)
            return label
        }()
        
        private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.showsHorizontalScrollIndicator = false
            cv.backgroundColor = .clear
            return cv
        }()
        
        private let collections = [
            WelcomeCollectionView(title: "Podcast hakkında sohbet et", description: "AI Sohbet", imageName: "background3", destinationType: .chat),
            WelcomeCollectionView(title: "Yeni bir podcast oluştur", description: "AI Üretim", imageName: "background2", destinationType: .create)
        ]
    
    private lazy var welcomeSecondLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "Günün sözünü okudun mu?"
        return label
    }()
        // MARK: - Card View Components
        private let cardView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "anaTemaRenk")
            view.layer.cornerRadius = 12
            view.clipsToBounds = true
            return view
        }()
    
        private let cardTitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 19, weight: .semibold)
            label.textColor = .white
            label.numberOfLines = 2
            label.text = "Günün Motivasyonu"
            return label
        }()
        private let cardContentLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 13)
            label.textColor = .white
            label.text = "Başarı, düştüğün her seferinde bir kez daha ayağa kalkabilme cesaretindir. Hedeflerine odaklan, geçmişin seni değil, geleceğin seni tanımlasın."
            label.numberOfLines = 0
            return label
        }()
    
        // MARK: - Lifecycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WelcomeCollectionViewCell.self, forCellWithReuseIdentifier: "WelcomeCollectionViewCell")
            
            configureView()
            updateWelcomeMessage()
            updateMotivationText()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateWelcomeMessage()
            updateMotivationText()
        }
        
        private func updateWelcomeMessage() {
            let userName = viewModel.getUserName()
            welcomeTitle.text = "Welcome \(userName)"
        }
        
        private func updateMotivationText() {
            if let motivation = viewModel.dailyMotivation {
                cardContentLabel.text = motivation
            } else {
                cardContentLabel.text = "Başarı, düştüğün her seferinde bir kez daha ayağa kalkabilme cesaretindir. Hedeflerine odaklan, geçmişin seni değil, geleceğin seni tanımlasın."
            }
        }
        
        
    }

// MARK: - UICollectionView Delegate and DataSource
    extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return collections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let collectionViews = collections[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeCollectionViewCell", for: indexPath) as! WelcomeCollectionViewCell
            cell.configure(with: collectionViews)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout
            collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 280, height: 160)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedCollection = collections[indexPath.item]
            
            guard let tabBarController = self.tabBarController else { return }
            
            switch selectedCollection.destinationType {
            case .chat:
                tabBarController.selectedIndex = 1
                
            case .create:
                tabBarController.selectedIndex = 2
                
            case .details:
                break
            }
        }
}

// MARK: - View Configuration
extension HomeViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        title = "Home"
        
        addViews()
        configureLayout()
    }
    func addViews() {
        view.addSubview(welcomeTitle)
        view.addSubview(collectionView)
        view.addSubview(cardView)
        view.addSubview(welcomeSecondLabel)
        cardView.addSubview(cardTitleLabel)
        cardView.addSubview(cardContentLabel)
    }
    func configureLayout() {
        welcomeTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(welcomeTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        welcomeSecondLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.top).offset(-34)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        cardView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(96)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(370)
            make.height.equalTo(210)
        }
        
        cardTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        cardContentLabel.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
}

#Preview {
    HomeViewController()
}
