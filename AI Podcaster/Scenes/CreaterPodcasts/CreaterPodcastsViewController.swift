//
//  CreaterPodcastsViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit
import AVFoundation

final class CreaterPodcastsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CreaterPodcastsViewModel
    
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
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Your AI Podcast"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .systemIndigo
        label.textAlignment = .center
        return label
    }()
    
    private lazy var promptContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.text = "Podcast Topic"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var promptTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter podcast topic or question"
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private lazy var settingsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Podcast Settings"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var durationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = .systemIndigo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration: 5 minutes"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 10
        slider.value = 5
        slider.tintColor = .systemIndigo
        slider.setThumbImage(UIImage(systemName: "circle.fill")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal), for: .normal)
        slider.addTarget(self, action: #selector(durationSliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var styleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.note")
        imageView.tintColor = .systemIndigo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var styleLabel: UILabel = {
        let label = UILabel()
        label.text = "Style"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var styleSegmentedControl: UISegmentedControl = {
        let items = ["Technical", "Fun", "Professional", "Companion"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemIndigo
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentedControl
    }()
    
    private lazy var languageIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "globe")
        imageView.tintColor = .systemIndigo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.text = "Language"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var chooseSpeakLanguage: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .systemBackground
        return picker
    }()
    
    private var selectedLanguage: String {
        let index = chooseSpeakLanguage.selectedRow(inComponent: 0)
        return viewModel.getLanguageName(at: index)
    }
    
    private lazy var actionsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemIndigo
        config.baseForegroundColor = .white
        config.title = "Create Podcast"
        config.image = UIImage(systemName: "wand.and.stars")
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        button.configuration = config
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white
        config.title = "Play"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        button.configuration = config
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.isEnabled = false
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var outputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var outputLabel: UILabel = {
        let label = UILabel()
        label.text = "Podcast Content"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var responseTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.title = "Save Podcast"
        config.image = UIImage(systemName: "arrow.down.doc.fill")
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        button.configuration = config
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: CreaterPodcastsViewModel = CreaterPodcastsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupViewModel()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func durationSliderValueChanged() {
        let duration = Int(durationSlider.value)
        durationLabel.text = "Duration: \(duration) minutes"
    }
    
    @objc private func createButtonTapped() {
        let prompt = promptTextField.text ?? ""
        let duration = Int(durationSlider.value)
        let selectedStyle = styleSegmentedControl.titleForSegment(at: styleSegmentedControl.selectedSegmentIndex) ?? ""
        
        responseTextView.text = "Generating podcast content..."
        responseTextView.textAlignment = .center
        playPauseButton.isEnabled = false
        
        viewModel.generatePodcast(prompt: prompt, duration: duration, style: selectedStyle, language: selectedLanguage)
    }
    
    @objc private func playPauseButtonTapped() {
        viewModel.togglePlayback()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        let saveVC = SavePodcastViewController(
            podcastText: responseTextView.text,
            podcastLanguage: selectedLanguage,
            podcastStyle: styleSegmentedControl.titleForSegment(at: styleSegmentedControl.selectedSegmentIndex) ?? ""
            
        )
        saveVC.delegate = self
        saveVC.modalPresentationStyle = .pageSheet
        
        if let sheet = saveVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(saveVC, animated: true)
    }
    
    // MARK: - Private Methods
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CreaterPodcastsViewModelDelegate
extension CreaterPodcastsViewController: CreaterPodcastsViewModelDelegate {
    func didUpdateResponse(_ response: String) {
        responseTextView.text = response
        playPauseButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    func didUpdatePlaybackState(isPlaying: Bool) {
        var config = playPauseButton.configuration
        config?.title = isPlaying ? "Pause" : "Play"
        config?.image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        config?.baseBackgroundColor = isPlaying ? .systemOrange : .systemGreen
        playPauseButton.configuration = config
    }
    
    func didShowError(_ error: String) {
        responseTextView.text = "Error: \(error)"
        playPauseButton.isEnabled = false
        saveButton.isEnabled = false
    }
    
    func didUpdateUIState(isLoading: Bool) {
        createButton.isEnabled = !isLoading
        if isLoading {
            responseTextView.text = "Generating podcast content..."
        }
    }
    
    func didShowAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func didSavePodcastSuccessfully() {
        showAlert(message: "Podcast saved successfully!")
    }
}

// MARK: - UI Setup
private extension CreaterPodcastsViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        title = "Create Podcast"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        addViews()
        configureLayout()
    }
    
    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header
        contentView.addSubview(headerView)
        headerView.addSubview(headerLabel)
        
        // Prompt Section
        contentView.addSubview(promptContainer)
        promptContainer.addSubview(promptLabel)
        promptContainer.addSubview(promptTextField)
        
        // Settings Section
        contentView.addSubview(settingsContainer)
        settingsContainer.addSubview(settingsLabel)
        
        settingsContainer.addSubview(durationIcon)
        settingsContainer.addSubview(durationLabel)
        settingsContainer.addSubview(durationSlider)
        
        settingsContainer.addSubview(styleIcon)
        settingsContainer.addSubview(styleLabel)
        settingsContainer.addSubview(styleSegmentedControl)
        
        settingsContainer.addSubview(languageIcon)
        settingsContainer.addSubview(languageLabel)
        settingsContainer.addSubview(chooseSpeakLanguage)
        
        // Actions
        contentView.addSubview(actionsContainer)
        actionsContainer.addSubview(createButton)
        actionsContainer.addSubview(playPauseButton)
        
        // Output Section
        contentView.addSubview(outputContainer)
        outputContainer.addSubview(outputLabel)
        outputContainer.addSubview(responseTextView)
        outputContainer.addSubview(saveButton)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Header
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        // Prompt Section
        promptContainer.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        promptLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        promptTextField.snp.makeConstraints { make in
            make.top.equalTo(promptLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Settings Section
        settingsContainer.snp.makeConstraints { make in
            make.top.equalTo(promptContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        settingsLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        durationIcon.snp.makeConstraints { make in
            make.top.equalTo(settingsLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(durationIcon)
            make.leading.equalTo(durationIcon.snp.trailing).offset(8)
        }
        
        durationSlider.snp.makeConstraints { make in
            make.top.equalTo(durationIcon.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        styleIcon.snp.makeConstraints { make in
            make.top.equalTo(durationSlider.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        styleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(styleIcon)
            make.leading.equalTo(styleIcon.snp.trailing).offset(8)
        }
        
        styleSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(styleIcon.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        languageIcon.snp.makeConstraints { make in
            make.top.equalTo(styleSegmentedControl.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(languageIcon)
            make.leading.equalTo(languageIcon.snp.trailing).offset(8)
        }
        
        chooseSpeakLanguage.snp.makeConstraints { make in
            make.top.equalTo(languageIcon.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Actions
        actionsContainer.snp.makeConstraints { make in
            make.top.equalTo(settingsContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        createButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Output Section
        outputContainer.snp.makeConstraints { make in
            make.top.equalTo(actionsContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        outputLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        responseTextView.snp.makeConstraints { make in
            make.top.equalTo(outputLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(responseTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

extension CreaterPodcastsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getLanguageName(at: row)
    }
}

extension CreaterPodcastsViewController: SavePodcastViewControllerDelegate {
    func didSavePodcast(title: String) {
        let style = styleSegmentedControl.titleForSegment(at: styleSegmentedControl.selectedSegmentIndex) ?? ""
        let podcastId = UUID()
        viewModel.savePodcast(id: podcastId, title: title, style: style, language: selectedLanguage, duration: Int(durationSlider.value))
    }
}

