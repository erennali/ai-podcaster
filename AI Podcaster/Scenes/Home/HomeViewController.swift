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
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
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
            WelcomeCollectionView(title: NSLocalizedString("podcastTitle", comment: ""), description: NSLocalizedString("podcastChatDescription", comment: ""), imageName: "background3", destinationType: .chat),
            WelcomeCollectionView(title: NSLocalizedString("podcastTitle2", comment: ""), description: NSLocalizedString("podcastChatDescription2", comment: ""), imageName: "background2", destinationType: .create)
        ]
    
    private lazy var welcomeSecondLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = NSLocalizedString("welcomeMotivation", comment: "")
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
            label.text = NSLocalizedString("dailyMotivation", comment: "")
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
    private let podcastCountCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "anaTemaRenk")
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private let podcastCountLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
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
            updatePodcastCountView()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateWelcomeMessage()
            updateMotivationText()
        }
        
        private func updateWelcomeMessage() {
            let userName = viewModel.getUserName()
            welcomeTitle.text = "\(NSLocalizedString("welcomeText", comment: "")) \(userName)"
        }
        
        private func updateMotivationText() {
            if let motivation = viewModel.dailyMotivation {
                cardContentLabel.text = motivation
            } else {
                cardContentLabel.text = "Başarı, düştüğün her seferinde bir kez daha ayağa kalkabilme cesaretindir. Hedeflerine odaklan, geçmişin seni değil, geleceğin seni tanımlasın."
            }
        }
    private func updatePodcastCountView() {
        let podcastCount: () = viewModel.getPodcastCount(completion: { count in
            DispatchQueue.main.async {
                self.podcastCountLabel.text = "\(NSLocalizedString("createdPodcastText", comment: "")) \(count)\n\n\(NSLocalizedString("greatText", comment: ""))"
            }
        })
        
        
    }}

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
        
        addViews()
        configureLayout()
    }
    func addViews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(welcomeTitle)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(welcomeSecondLabel)
        scrollView.addSubview(cardView)
        scrollView.addSubview(podcastCountCardView)
        
        cardView.addSubview(cardTitleLabel)
        cardView.addSubview(cardContentLabel)
        podcastCountCardView.addSubview(podcastCountLabel)
    }
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
        }
        
        welcomeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(welcomeTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        
        welcomeSecondLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(welcomeSecondLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        cardTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        cardContentLabel.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel.snp.bottom).offset(21)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        podcastCountCardView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(view.snp.width).offset(-32)
            make.height.equalTo(90)
            make.bottom.equalToSuperview().offset(-20) // Scroll view için alt boşluk
        }
        
        podcastCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

#Preview {
    HomeViewController()
}
