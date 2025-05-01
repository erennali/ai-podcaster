//
//  CreaterPodcastsViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit

class CreaterPodcastsViewController: UIViewController {
    
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
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var responseLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func durationSliderValueChanged() {
        let duration = Int(durationSlider.value)
        durationLabel.text = "Time: \(duration) minutes"
    }
    
    @objc private func sendButtonTapped() {
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
        
        responseLabel.text = "Awaiting a response..."
        
        let podcastPrompt = "Create a podcast content that I can convert into an audio file by typing it into the text to speech AI tool in the subject \(prompt), with a reading time \(duration) minutes, with a style \(selectedStyle). Write the podcast content directly and only in paragraphs, don't write anything else. Only 1 person will voice the podcast, write accordingly "
        
        GoogleAIService.shared.generateAIResponse(prompt: podcastPrompt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.responseLabel.text = response
                case .failure(let error):
                    self?.responseLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UI Setup
private extension CreaterPodcastsViewController {

    private func configureView() {
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
        contentView.addSubview(sendButton)
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
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(styleSegmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        responseLabel.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
