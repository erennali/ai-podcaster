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
    private var isPlaying = false
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    private let podcastImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        imageView.image = UIImage(systemName: "mic.fill")
        imageView.tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
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
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let minutesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let styleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let styleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let languageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let createdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        updateAppearanceForCurrentTraitCollection() // Set initial appearance
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
            self.containerView.backgroundColor = selected ? .secondarySystemBackground : .systemBackground
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if isPlaying {
            stopSpeech()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearanceForCurrentTraitCollection()
        }
    }
    
    private func updateAppearanceForCurrentTraitCollection() {
        if traitCollection.userInterfaceStyle == .dark {
            // Dark mode - add border for better separation
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            containerView.layer.shadowOpacity = 0.25
            containerView.layer.shadowRadius = 6
        } else {
            // Light mode - use shadow only
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowRadius = 4
        }
        
        // Update shadow color based on current interface style
        containerView.layer.shadowColor = UIColor.label.cgColor
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
        setupActions()
    }
    
    func addViews() {
        contentView.addSubview(containerView)
        
        
        containerView.addSubview(podcastImageView)
        containerView.addSubview(playButton)
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
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(podcastImageView.snp.bottom).offset(8)
            make.centerX.equalTo(podcastImageView)
            make.width.height.equalTo(32)
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
    
    func setupActions() {
        playButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
    }
    
    @objc func togglePlayPause() {
        guard let podcast = podcast else { return }
        
        if isPlaying {
            stopSpeech()
        } else {
            startSpeech(with: podcast.content)
        }
    }
    
    func startSpeech(with text: String) {
        AVSpeechService.shared.speak(text: text)
        isPlaying = true
        updatePlayButtonState()
        
        // Register for speech completion notification
        NotificationCenter.default.addObserver(self, 
                                              selector: #selector(speechDidFinish), 
                                              name: NSNotification.Name("AVSpeechSynthesizerDidFinishSpeechUtterance"), 
                                              object: nil)
    }
    
    func stopSpeech() {
        AVSpeechService.shared.stop()
        isPlaying = false
        updatePlayButtonState()
        
        // Remove observer
        NotificationCenter.default.removeObserver(self, 
                                                name: NSNotification.Name("AVSpeechSynthesizerDidFinishSpeechUtterance"), 
                                                object: nil)
    }
    
    @objc func speechDidFinish() {
        isPlaying = false
        updatePlayButtonState()
    }
    
    func updatePlayButtonState() {
        let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
