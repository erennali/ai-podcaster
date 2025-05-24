//
//  RegisterViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 29.04.2025.
//

import UIKit
import SnapKit

class RegisterViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MyAppIcon")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor(named: "anaTemaRenk")?.withAlphaComponent(0.3).cgColor
        return imageView
    }()
    
    private lazy var logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        // Move shadow properties to container view
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.15
        view.layer.masksToBounds = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join AI Podcaster to start creating amazing podcasts"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Full Name"
        textField.icon = UIImage(systemName: "person.fill")
        return textField
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Email Address"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.icon = UIImage(systemName: "envelope.fill")
        return textField
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.icon = UIImage(systemName: "lock.fill")
        return textField
    }()
    
    private lazy var confirmPasswordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.icon = UIImage(systemName: "lock.fill")
        return textField
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(named: "anaTemaRenk")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        attributedTitle.append(NSAttributedString(
            string: "Sign In",
            attributes: [.foregroundColor: UIColor(named: "anaTemaRenk") ?? .systemBlue]
        ))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    private let viewModel = RegisterViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Scroll view'ı en üste taşı
        DispatchQueue.main.async { [weak self] in
            self?.scrollView.setContentOffset(.zero, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
        
        [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.delegate = self
        }
    }
    
    // MARK: - Actions
    @objc private func registerButtonTapped() {
        guard let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showErrorAlert(message: "Please fill in all fields")
            return
        }
        
        if password != confirmPassword {
            showErrorAlert(message: "Passwords do not match")
            return
        }
        
        viewModel.updateName(nameTextField.text ?? "")
        viewModel.updateEmail(emailTextField.text ?? "")
        viewModel.updatePassword(password)
        viewModel.register()
    }
    
    @objc private func loginButtonTapped() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardSize.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        let adjustedKeyboardHeight = keyboardHeight - safeAreaBottom
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: adjustedKeyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Aktif metin alanının görünür kalmasını sağla
        if let activeField = [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField].first(where: { $0.isFirstResponder }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                let activeFieldFrame = activeField.convert(activeField.bounds, to: self.scrollView)
                let targetRect = CGRect(x: 0, y: activeFieldFrame.origin.y - 20, width: self.scrollView.frame.width, height: activeFieldFrame.height + 40)
                self.scrollView.scrollRectToVisible(targetRect, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - UI Configuration
extension RegisterViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        title = "Register"
        
        addViews()
        configureLayout()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [logoContainerView, titleLabel, subtitleLabel, nameTextField, emailTextField,
         passwordTextField, confirmPasswordTextField, registerButton, loginButton, activityIndicator].forEach {
            contentView.addSubview($0)
        }
        
        logoContainerView.addSubview(logoImageView)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
            make.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide).priority(.low)
        }
        
        logoContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(registerButton)
        }
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - RegisterViewModelDelegate
extension RegisterViewController: RegisterViewModelDelegate {
    func registrationDidStart() {
        registerButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func registrationDidComplete() {
        activityIndicator.stopAnimating()
        registerButton.isEnabled = true
        showSuccessAlert()
    }
    
    func registrationDidFail(with error: String) {
        activityIndicator.stopAnimating()
        registerButton.isEnabled = true
        showErrorAlert(message: error)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Your account has been created successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
     private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CustomTextField
class CustomTextField: UITextField {
    var icon: UIImage? {
        didSet {
            updateIcon()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        rightView = rightPaddingView
        rightViewMode = .always
    }
    
    private func updateIcon() {
        guard let icon = icon else { return }
        let iconView = UIImageView(image: icon)
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: frame.height))
        iconView.frame = CGRect(x: 10, y: (containerView.frame.height - 20) / 2, width: 20, height: 20)
        containerView.addSubview(iconView)
        
        leftView = containerView
        leftViewMode = .always
    }
}
