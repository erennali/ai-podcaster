//
//  PodcastsCell.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 20.05.2025.
//

import UIKit
import SnapKit
import FirebaseFirestore

class PodcastsCell: UITableViewCell {

    static let identifier = "PodcastsCell"

    private var podcast: Podcast?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let podcastImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        imageView.image = UIImage(systemName: "mic.fill")
        imageView.tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    private let minutesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let minutesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let styleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let styleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let languageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let createdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.backgroundColor = selected ? UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0) : .white
        }
    }
}

// MARK: - Public Methods
extension PodcastsCell {
    func configure(with podcast: Podcast) {
        self.podcast = podcast
        titleLabel.text = podcast.title
        contentLabel.text = podcast.content
        minutesLabel.text = "\(podcast.minutes) min"
        styleLabel.text = podcast.style
        languageLabel.text = podcast.language
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = podcast.createdAt.dateValue()
        createdLabel.text = dateFormatter.string(from: date)
    }
}

// MARK: - Private Methods
private extension PodcastsCell {
    func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addViews()
        configureLayout()
    }
    
    func addViews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(podcastImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        containerView.addSubview(infoStackView)
        containerView.addSubview(createdLabel)
        
        // Add containers to stack view
        infoStackView.addArrangedSubview(minutesContainer)
        infoStackView.addArrangedSubview(styleContainer)
        infoStackView.addArrangedSubview(languageContainer)
        
        // Add labels to containers
        minutesContainer.addSubview(minutesLabel)
        styleContainer.addSubview(styleLabel)
        languageContainer.addSubview(languageLabel)
    }
    
    func configureLayout() {
        podcastImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(podcastImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(podcastImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.leading.equalTo(podcastImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(28)
        }
        
        minutesLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        styleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        createdLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(12)
            make.leading.equalTo(podcastImageView.snp.trailing).offset(12)
            make.trailing.bottom.equalToSuperview().inset(16)
        }
    }
}
