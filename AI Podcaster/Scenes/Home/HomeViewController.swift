//
//  HomeViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
    private let welcomeTitle: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 24)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.showsHorizontalScrollIndicator = false
            cv.backgroundColor = .clear
            return cv
        }()
        
        private let podcasts = [
            PodcastTest(title: "Yapay Zeka İşimizi Elimizden Alacak mı?", duration: "11d"),
            PodcastTest(title: "Sezon 1 Bölüm 1", duration: "9d")
        ]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            view.addSubview(welcomeTitle)
            view.addSubview(collectionView)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(PodcastTestCell.self, forCellWithReuseIdentifier: "PodcastTestCell")
            
            setupConstraints()
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
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                welcomeTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                welcomeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                collectionView.topAnchor.constraint(equalTo: welcomeTitle.bottomAnchor, constant: 16),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: 160)
            ])
        }
    }

    extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return podcasts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let podcastTest = podcasts[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PodcastTestCell", for: indexPath) as! PodcastTestCell
            cell.configure(with: podcastTest)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout
            collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 280, height: 160)
        }
}
