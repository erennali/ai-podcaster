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
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var promptTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please enter a question or request"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 10
        slider.value = 5
        slider.addTarget(self, action: #selector(durationSliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Time: 5 minutes"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var styleSegmentedControl: UISegmentedControl = {
        let items = ["Technical", "Fun", "Professional", "Companion"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Language"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var chooseSpeakLanguage: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .systemBackground
        return picker
    }()
    
    private let languages = [
        ("Türkçe", "tr-TR"),
        ("English (US)", "en-US"),
        ("English (UK)", "en-GB"),
        ("Español", "es-ES"),
        ("Français", "fr-FR"),
        ("Deutsch", "de-DE"),
        ("Italiano", "it-IT"),
        ("Português", "pt-BR"),
        ("Русский", "ru-RU"),
        ("日本語", "ja-JP"),
        ("한국어", "ko-KR"),
        ("中文", "zh-CN"),
        ("العربية", "ar-SA")
    ]
    
    private var selectedLanguage: String {
        let index = chooseSpeakLanguage.selectedRow(inComponent: 0)
        return languages[index].1
    }
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Podcast", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.isEnabled = false
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var responseLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
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
        durationLabel.text = "Time: \(duration) minutes"
    }
    
    @objc private func createButtonTapped() {
        if SceneDelegate.loginUser == false {
            showAlert(message: "You must be logged in to use this feature!")
            return
        }
        
        guard let prompt = promptTextField.text, !prompt.isEmpty else {
            showAlert(message: "Please enter a question or request")
            return
        }
        
        let duration = Int(durationSlider.value)
        let selectedStyle = styleSegmentedControl.titleForSegment(at: styleSegmentedControl.selectedSegmentIndex) ?? ""
        let selectedLanguage = languages[chooseSpeakLanguage.selectedRow(inComponent: 0)].0
        
        responseLabel.text = "Awaiting a response..."
        playPauseButton.isEnabled = false
        
        viewModel.generatePodcast(prompt: prompt, duration: duration, style: selectedStyle, language: selectedLanguage)
    }
    
    @objc private func playPauseButtonTapped() {
        viewModel.togglePlayback()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func setupViewModel() {
        viewModel.delegate = self
    }
}

// MARK: - CreaterPodcastsViewModelDelegate
extension CreaterPodcastsViewController: CreaterPodcastsViewModelDelegate {
    func didUpdateResponse(_ response: String) {
        responseLabel.text = response
        playPauseButton.isEnabled = true
    }
    
    func didUpdatePlaybackState(isPlaying: Bool) {
        playPauseButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        playPauseButton.backgroundColor = isPlaying ? .systemOrange : .systemGreen
    }
    
    func didShowError(_ error: String) {
        responseLabel.text = "Error: \(error)"
        playPauseButton.isEnabled = false
    }
}

// MARK: - UI Setup
private extension CreaterPodcastsViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        title = "AI Podcaster"
        
        addViews()
        configureLayout()
    }
    
    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(promptTextField)
        contentView.addSubview(durationSlider)
        contentView.addSubview(durationLabel)
        contentView.addSubview(styleSegmentedControl)
        contentView.addSubview(languageLabel)
        contentView.addSubview(chooseSpeakLanguage)
        contentView.addSubview(createButton)
        contentView.addSubview(playPauseButton)
        contentView.addSubview(responseLabel)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        promptTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(promptTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        durationSlider.snp.makeConstraints { make in
            make.top.equalTo(durationLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        styleSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(durationSlider.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        languageLabel.snp.makeConstraints { make in
            make.top.equalTo(styleSegmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        chooseSpeakLanguage.snp.makeConstraints { make in
            make.top.equalTo(languageLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        createButton.snp.makeConstraints { make in
            make.top.equalTo(chooseSpeakLanguage.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        responseLabel.snp.makeConstraints { make in
            make.top.equalTo(playPauseButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}

extension CreaterPodcastsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].0
    }
}

