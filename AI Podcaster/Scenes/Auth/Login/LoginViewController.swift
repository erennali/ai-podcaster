//
//  LoginViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 30.04.2025.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    private let viewModel = LoginViewModel()
    
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
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.15
        view.layer.masksToBounds = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("login", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("welcomeBack", comment: "")
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var lostPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("forgotPassword", comment: ""), for: .normal)
        button.setTitleColor(UIColor(named: "anaTemaRenk"), for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return button
    }()
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("email", comment: "")
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("password", comment: "")
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 12
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var loginButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "anaTemaRenk")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureView()
        setupViewModel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }

    @objc func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        // Show loading state
        setLoadingState(true)
        
        viewModel.login(email: email, password: password)
    }
    
    @objc func forgotPasswordTapped() {
        guard let email = emailTextField.text else { return }
        viewModel.resetPassword(email: email)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showErrorAlert(message: String) {
       let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default))
       present(alert, animated: true)
   }

    private func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            loginButton.setTitle("", for: .normal)
            loginButton.isEnabled = false
            activityIndicator.startAnimating()
        } else {
            loginButton.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
            loginButton.isEnabled = true
            activityIndicator.stopAnimating()
        }
    }

}
// MARK: - View Configuration
extension LoginViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        addViews()
        configureLayout()
    }
    func addViews() {
        view.addSubview(logoContainerView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(lostPasswordButton)
        
        logoContainerView.addSubview(logoImageView)
        loginButton.addSubview(activityIndicator)
        
    }
    
    func configureLayout() {
        logoContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainerView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        lostPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
}

// MARK: - LoginViewModelDelegate
extension LoginViewController: LoginViewModelDelegate {
    func didLoginSuccessfully() {
        setLoadingState(false)
        let splashVC = SplashViewController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(splashVC)
        }
    }
    
    func didFailToLogin(with error: String) {
        setLoadingState(false)
        showErrorAlert(message: error)
    }
    
    func didSendPasswordReset() {
        let alert = UIAlertController(title: NSLocalizedString("success", comment: ""), message: NSLocalizedString("passwordReset", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func didFailToSendPasswordReset(with error: String) {
        showErrorAlert(message: error)
    }
}


