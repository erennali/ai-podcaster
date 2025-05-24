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
        label.text = "Login"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back to AI Podcaster"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var lostPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(UIColor(named: "anaTemaRenk"), for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return button
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
        return textField
    }()
    
    private lazy var loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "anaTemaRenk")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureView()
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }

    @objc func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.login(email: email, password: password)
    }
    
    @objc func forgotPasswordTapped() {
        guard let email = emailTextField.text else { return }
        viewModel.resetPassword(email: email)
    }

    private func showErrorAlert(message: String) {
       let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default))
       present(alert, animated: true)
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
        let splashVC = SplashViewController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(splashVC)
        }
    }
    
    func didFailToLogin(with error: String) {
        showErrorAlert(message: error)
    }
    
    func didSendPasswordReset() {
        let alert = UIAlertController(title: "Success", message: "Password reset email sent!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func didFailToSendPasswordReset(with error: String) {
        showErrorAlert(message: error)
    }
}


