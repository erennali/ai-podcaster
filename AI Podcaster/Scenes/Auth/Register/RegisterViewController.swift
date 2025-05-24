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
    private lazy var logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.15
        view.layer.masksToBounds = false
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
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email Address"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        textField.leftViewMode = .always
        textField.delegate = self
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
    private var originalViewY: CGFloat = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObservers()
        originalViewY = view.frame.origin.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
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
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        let adjustedKeyboardHeight = keyboardHeight - safeAreaBottom
        
        // Aktif text field'ın pozisyonunu kontrol et
        if let activeTextField = findActiveTextField() {
            let textFieldBottomY = activeTextField.frame.maxY + activeTextField.superview!.frame.origin.y
            let visibleHeight = view.frame.height - adjustedKeyboardHeight
            
            if textFieldBottomY > visibleHeight {
                let offsetY = textFieldBottomY - visibleHeight + 20
                
                UIView.animate(withDuration: duration) {
                    self.view.frame.origin.y = self.originalViewY - offsetY
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = self.originalViewY
        }
    }
    
    private func findActiveTextField() -> UITextField? {
        return [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
            .first { $0.isFirstResponder }
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
        view.addSubview(logoContainerView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        view.addSubview(activityIndicator)
        
        logoContainerView.addSubview(logoImageView)
    }
    
    func configureLayout() {
        logoContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
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




