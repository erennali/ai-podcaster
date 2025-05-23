//
//  PodcastTestCell.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit
import SnapKit

class WelcomeCollectionViewCell: UICollectionViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Hücre için sabit boyut
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
        
        configureView()
    }
    
    
    func configure(with item: WelcomeCollectionView) {
        titleLabel.text = item.title
        durationLabel.text = item.description
        
        if let imageName = item.imageName {
            backgroundImageView.image = UIImage(named: imageName)
            
            // Overlay ekleme - her seferinde yeni overlay eklemek yerine bir kez ekleyelim
            if cardView.subviews.count == 3 { // backgroundImageView, titleLabel ve durationLabel
                let overlayView = UIView()
                overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                cardView.insertSubview(overlayView, aboveSubview: backgroundImageView)
                
                // Overlay için constraint
                overlayView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        } else {
            backgroundImageView.image = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WelcomeCollectionViewCell {
    func configureView() {
        addViews()
        configureLayout()
    }
    
    func addViews() {
        contentView.addSubview(cardView)
        cardView.addSubview(backgroundImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(durationLabel)
    }
    
    func configureLayout() {
       
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(160)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
