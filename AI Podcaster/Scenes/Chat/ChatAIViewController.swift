//
//  ChatAIViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 23.05.2025.
//

import UIKit
import SnapKit

// MARK: - Chat AI View Controller
final class ChatAIViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ChatViewModelProtocol
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: ChatMessageCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var chatInputView: ChatInputView = {
        let inputView = ChatInputView()
        inputView.delegate = self
        return inputView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let label = UILabel()
        label.text = "Start chatting with your AI Podcast assistant!"
        label.textAlignment = .center
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        return view
    }()
    
    // MARK: - Initialization
    init(viewModel: ChatViewModelProtocol = ChatViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
        setupKeyboardObservers()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup Methods
private extension ChatAIViewController {
    
    func setupView() {
        view.backgroundColor = .systemBackground
        title = "AI Chat"
        
        addViews()
        configureLayout()
        setupNavigationBar()
    }
    
    func addViews() {
        view.addSubview(collectionView)
        view.addSubview(chatInputView)
        view.addSubview(emptyStateView)
    }
    
    func configureLayout() {
        chatInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(chatInputView.snp.top)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
    
    func setupNavigationBar() {
        let clearButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearChatTapped)
        )
        clearButton.tintColor = UIColor(named: "anaTemaRenk")
        navigationItem.rightBarButtonItem = clearButton
    }
    
    func setupViewModel() {
        viewModel.delegate = self
    }
    
    func loadInitialData() {
        viewModel.loadInitialMessages()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - Actions
private extension ChatAIViewController {
    
    @objc func clearChatTapped() {
        let alert = UIAlertController(
            title: "Clear Chat",
            message: "Are you sure you want to delete all messages?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.clearChat()
        })
        
        present(alert, animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        
        chatInputView.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(keyboardHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to bottom when keyboard appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        chatInputView.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Helper Methods
private extension ChatAIViewController {
    
    func scrollToBottom(animated: Bool = true) {
        guard !viewModel.messages.isEmpty else { return }
        let indexPath = IndexPath(item: viewModel.messages.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }
    
    func updateEmptyState() {
        emptyStateView.isHidden = !viewModel.messages.isEmpty
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ChatAIViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatMessageCell.identifier,
            for: indexPath
        ) as! ChatMessageCell
        
        cell.configure(with: viewModel.messages[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChatAIViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = viewModel.messages[indexPath.item]
        let maxWidth = collectionView.frame.width
        return ChatMessageCell.sizeForMessage(message, maxWidth: maxWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - ChatInputViewDelegate
extension ChatAIViewController: ChatInputViewDelegate {
    
    func chatInputView(_ inputView: ChatInputView, didSendMessage message: String) {
        viewModel.sendMessage(message)
    }
}

// MARK: - ChatViewModelDelegate
extension ChatAIViewController: ChatViewModelDelegate {
    
    func didUpdateMessages() {
        collectionView.reloadData()
        updateEmptyState()
        scrollToBottom()
    }
    
    func didUpdateChatState(_ state: ChatState) {
        switch state {
        case .idle:
            chatInputView.setLoading(false)
        case .loading:
            chatInputView.setLoading(true)
        case .error:
            chatInputView.setLoading(false)
        }
    }
    
    func didFailWithError(_ error: String) {
        showErrorAlert(message: error)
    }
    
    func didReceiveAIResponse() {
     
    }
}

