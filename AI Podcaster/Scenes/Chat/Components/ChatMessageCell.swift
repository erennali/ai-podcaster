//
//  ChatMessageCell.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit
import SnapKit

final class ChatMessageCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "ChatMessageCell"
    
    // MARK: - UI Components
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }
    
    // MARK: - Configuration
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        timestampLabel.text = formatTimestamp(message.timestamp)
        
        if message.isFromUser {
            configureUserMessage()
        } else {
            configureAIMessage()
        }
    }
    
    // MARK: - Override
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        attributes.frame.size.height = fittingSize.height
        return attributes
    }
    
    // MARK: - Static Methods
    static func sizeForMessage(_ message: ChatMessage, maxWidth: CGFloat) -> CGSize {
        let bubbleMaxWidth = maxWidth - 32 // Leave 16px margin on each side
        let labelWidth = bubbleMaxWidth - 28 // Subtract padding (14 * 2)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = message.text
        label.numberOfLines = 0
        
        let labelSize = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        let bubbleHeight = labelSize.height + 20 // Add padding (10 * 2)
        
        return CGSize(width: maxWidth, height: bubbleHeight + 24) // +24 for timestamp space
    }
}

// MARK: - Private Methods
private extension ChatMessageCell {
    
    func configureUserMessage() {
        bubbleView.backgroundColor = UIColor(named: "anaTemaRenk")
        messageLabel.textColor = .white
        timestampLabel.textColor = .systemGray
        
        bubbleView.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(16)
            make.leading.greaterThanOrEqualToSuperview().inset(60)
            make.width.greaterThanOrEqualTo(60)
        }
        
        timestampLabel.snp.remakeConstraints { make in
            make.top.equalTo(bubbleView.snp.bottom).offset(4)
            make.trailing.equalTo(bubbleView.snp.trailing)
            make.bottom.equalToSuperview().inset(4)
        }
    }
    
    func configureAIMessage() {
        bubbleView.backgroundColor = .systemGray5
        messageLabel.textColor = .label
        timestampLabel.textColor = .systemGray
        
        bubbleView.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(40)
            make.width.greaterThanOrEqualTo(60)
        }
        
        timestampLabel.snp.remakeConstraints { make in
            make.top.equalTo(bubbleView.snp.bottom).offset(4)
            make.leading.equalTo(bubbleView.snp.leading)
            make.bottom.equalToSuperview().inset(4)
        }
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 
