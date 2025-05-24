//
//  HomeViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit
import SnapKit

/*!!!!


- filter butonlar tıklanıldığı belli olmuyor, tıklanıldığı belli olsun
- arka plana alınınca da avspeach devam etmeli
- mypodcast te app giriş yapılı değilse hata dönüyor o kontrolu creatpodcast gibi yap(chatai da da)
- aichat de response textfield yetmiyor


!!! */

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WelcomeCollectionViewCell.self, forCellWithReuseIdentifier: "WelcomeCollectionViewCell")
            
            configureView()
            updateWelcomeMessage()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateWelcomeMessage()
        }
        
        private func updateWelcomeMessage() {
            let userName = viewModel.getUserName()
            welcomeTitle.text = "Welcome \(userName)"
        }
        
        
    }

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
                // Sohbet sekmesine geçiş yapma
                tabBarController.selectedIndex = 1  // Chat sekmesi için kullanılan indeks
                
            case .create:
                // Podcast oluşturma sekmesine geçiş yapma
                tabBarController.selectedIndex = 2  // Create Podcast sekmesi için kullanılan indeks
                
            case .details:
                // Diğer durumlar
                break
            }
        }
}

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
    }
}
