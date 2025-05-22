//
//  PodcastDetailsViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 22.05.2025.
//

import UIKit
import SnapKit

class PodcastDetailsViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: PodcastDetailsViewModel
    private var isPlaying = false
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var languageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private lazy var styleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var styleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private lazy var minutesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var minutesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private lazy var createdContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var createdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contentCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var contentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Content"
        label.textAlignment = .left
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var playbackControlsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var playbackControlsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        config.baseForegroundColor = .systemBlue
        button.configuration = config
        
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        config.baseForegroundColor = .systemRed
        button.configuration = config
        
        button.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Ready to play"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.title = "Delete Podcast"
        config.image = UIImage(systemName: "trash")
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        button.configuration = config
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        
        button.addTarget(self, action: #selector(deletePodcast), for: .touchUpInside)
        return button
    }()
    
    // MARK: Inits
    
    init(viewModel: PodcastDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isPlaying {
            stopPlayback()
        }
        removeNotifications()
    }
    
    // MARK: Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(speechDidFinish),
            name: NSNotification.Name("AVSpeechSynthesizerDidFinishSpeechUtterance"),
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("AVSpeechSynthesizerDidFinishSpeechUtterance"),
            object: nil
        )
    }
    
    @objc func speechDidFinish() {
        isPlaying = false
        updatePlaybackUI()
    }
}

//MARK: Private Methods

private extension PodcastDetailsViewController {
    
    func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        addViews()
        configureLayout()
        configureLabels()
    }
    
    // MARK: Add Views and Layout
    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        
        contentView.addSubview(infoStackView)
        
        
        // Add containers to stack view
        infoStackView.addArrangedSubview(languageContainer)
        infoStackView.addArrangedSubview(styleContainer)
        infoStackView.addArrangedSubview(minutesContainer)
        
        // Add labels to containers
        languageContainer.addSubview(languageLabel)
        styleContainer.addSubview(styleLabel)
        minutesContainer.addSubview(minutesLabel)
        
        contentView.addSubview(createdContainer)
        createdContainer.addSubview(createdLabel)
        
        contentView.addSubview(contentCard)
        contentCard.addSubview(contentTitleLabel)
        contentCard.addSubview(contentLabel)
        
        contentView.addSubview(playbackControlsContainer)
        playbackControlsContainer.addSubview(playbackControlsStack)
        playbackControlsContainer.addSubview(statusLabel)
        
        playbackControlsStack.addArrangedSubview(playPauseButton)
        playbackControlsStack.addArrangedSubview(stopButton)
        
        contentView.addSubview(deleteButton)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        styleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        minutesLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        createdContainer.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        
        createdLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        contentCard.snp.makeConstraints { make in
            make.top.equalTo(createdContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        playbackControlsContainer.snp.makeConstraints { make in
            make.top.equalTo(contentCard.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }
        
        playbackControlsStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(60)
            make.width.equalTo(180)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(playbackControlsStack.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(playbackControlsContainer.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(24)
        }
    }
    
    func configureLabels() {
        titleLabel.text = viewModel.podcast.title
        contentLabel.text = viewModel.podcast.content
        languageLabel.text = viewModel.podcast.language
        styleLabel.text = viewModel.podcast.style
        minutesLabel.text = "\(viewModel.podcast.minutes) min"
        
        // Format created date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = viewModel.podcast.createdAt.dateValue()
        createdLabel.text = dateFormatter.string(from: date)
    }
    
    @objc func playPauseButtonTapped() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    @objc func stopButtonTapped() {
        stopPlayback()
    }
    
    func startPlayback() {
        let speechService = AVSpeechService.shared
        
        if speechService.synthesizer.isPaused {
            speechService.resume()
        } else {
            speechService.speak(text: viewModel.podcast.content)
        }
        
        isPlaying = true
        updatePlaybackUI()
    }
    
    func pausePlayback() {
        let speechService = AVSpeechService.shared
        speechService.pause()
        
        isPlaying = false
        updatePlaybackUI()
    }
    
    func stopPlayback() {
        let speechService = AVSpeechService.shared
        speechService.stop()
        
        isPlaying = false
        statusLabel.text = "Ready to play"
        playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    }
    
    func updatePlaybackUI() {
        if isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            statusLabel.text = "Playing..."
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            statusLabel.text = "Paused"
        }
    }
    
    @objc func deletePodcast() {
        let alert = UIAlertController(
            title: "Delete Podcast",
            message: "Are you sure you want to delete this podcast? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        
        present(alert, animated: true)
    }
    
    func performDelete() {
        viewModel.deletePodcast { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showSuccessAlert()
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Podcast deleted successfully",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to delete podcast: \(message)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}
