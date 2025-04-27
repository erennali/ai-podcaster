//
//  CreaterPodcastsViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit

class CreaterPodcastsViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var promptTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Soru veya isteğinizi yazın..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gönder", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var responseLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "AI Podcaster"
        
        view.addSubview(promptTextField)
        view.addSubview(sendButton)
        view.addSubview(responseLabel)
        
        NSLayoutConstraint.activate([
            promptTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            promptTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptTextField.heightAnchor.constraint(equalToConstant: 44),
            
            sendButton.topAnchor.constraint(equalTo: promptTextField.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            responseLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            responseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            responseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let prompt = promptTextField.text, !prompt.isEmpty else {
            showAlert(message: "Lütfen bir soru veya istek girin")
            return
        }
        
        responseLabel.text = "Yanıt bekleniyor..."
        
        GoogleAIService.shared.generateAIResponse(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.responseLabel.text = response
                case .failure(let error):
                    self?.responseLabel.text = "Hata: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }


}
