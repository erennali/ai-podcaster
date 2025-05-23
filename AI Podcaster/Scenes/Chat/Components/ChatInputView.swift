//
//  ChatInputView.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit
import SnapKit

// MARK: - Chat Input View Delegate
protocol ChatInputViewDelegate: AnyObject {
    func chatInputView(_ inputView: ChatInputView, didSendMessage message: String)
}

// MARK: - Chat Input View
final class ChatInputView: UIView {
    
    // MARK: - Properties
    weak var delegate: ChatInputViewDelegate?
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 0.5
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        textView.isScrollEnabled = false
        textView.text = "Type your message..."
        textView.textColor = .systemGray3
        textView.delegate = self
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1.0)
        button.isEnabled = false
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setLoading(_ isLoading: Bool) {
        sendButton.isHidden = isLoading
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        textView.isEditable = !isLoading
    }
    
    func clearText() {
        textView.text = ""
        textView.textColor = .systemGray3
        textView.text = "Type your message..."
        sendButton.isEnabled = false
        updateTextViewHeight()
    }
}

// MARK: - Private Methods
private extension ChatInputView {
    
    func setupViews() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(sendButton)
        containerView.addSubview(loadingIndicator)
        
        configureLayout()
    }
    
    func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(64)
        }
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.right.equalTo(sendButton.snp.left).offset(-12)
            make.height.greaterThanOrEqualTo(40)
            make.height.lessThanOrEqualTo(100)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalTo(textView.snp.bottom).offset(-2)
            make.width.height.equalTo(32)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(sendButton)
        }
    }
    
    func updateTextViewHeight() {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        textView.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(min(max(size.height, 40), 100))
        }
    }
    
    @objc func sendButtonTapped() {
        guard let text = textView.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              textView.textColor != .systemGray3 else { return }
        
        delegate?.chatInputView(self, didSendMessage: text)
        clearText()
    }
}

// MARK: - UITextViewDelegate
extension ChatInputView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray3 {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your message..."
            textView.textColor = .systemGray3
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isEnabled = hasText && textView.textColor != .systemGray3
        updateTextViewHeight()
    }
} 
