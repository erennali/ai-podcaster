import UIKit
import StoreKit
import SafariServices
import RevenueCat

protocol SettingsViewControllerProtocol: AnyObject {
    func updateSwitchValue(_ value: Bool)
    func openAppSettings()
    func updateSubscriptionStatusLabel(_ text: String)
}

final class SettingsViewController: UIViewController {
    
    
    private let viewModel: SettingsViewModel
    private let themeKey = "selectedTheme"
    private let iapService = IAPService.shared
    
    // MARK: Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var notificationSwitch: UISwitch?
    private var subscriptionStatusLabel: UILabel?
    
    private let appVersionLabel: UILabel = {
        let label = UILabel()
        label.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    init(viewModel: SettingsViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        // Add observer for subscription status changes
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusChanged), name: .subscriptionStatusChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSubscriptionStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Objective Methods
@objc private extension SettingsViewController {
    func didChangeTheme(_ sender: UISegmentedControl) {
        updateThemeMode(to: sender.selectedSegmentIndex)
    }
    func didToggleNotification(_ sender: UISwitch) {
        viewModel.updateNotificationStatus(isOn: sender.isOn)
    }
    
    func subscriptionStatusChanged() {
        updateSubscriptionStatus()
    }
}
    


// MARK: - Private Methods
private extension SettingsViewController {
    func configureView() {
        view.backgroundColor = .systemGroupedBackground
        addViews()
        configureLayout()
    }
    func addViews() {
        view.addSubview(tableView)
        view.addSubview(appVersionLabel)
    }
    func configureLayout() {
        tableView.snp.makeConstraints { $0.edges.equalToSuperview()}
        appVersionLabel.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.centerX.equalToSuperview()
        }
    }
    func updateThemeMode(to mode: Int) {
        UserDefaults.standard.set(mode, forKey: themeKey)
        switch mode {
        case 1:
            view.window?.overrideUserInterfaceStyle = .light
        case 2:
            view.window?.overrideUserInterfaceStyle = .dark
        default:
            view.window?.overrideUserInterfaceStyle = .unspecified
        }
    }
    func didSelect(item: SettingsItem){
        switch item.type {
        case .rateApp : promptReview()
        case .deleteAccount:
            deleteAccount()
        case .privacyPolicy , .termsOfUse :
            openUrl("https://podcasterai.wordpress.com")
        case .subscription:
            showPaywall()
        case .restorePurchases:
            restorePurchases()
        default : break
        }
    }
    func deleteAccount() {
        let splashVC = SplashViewController()
        let alert = UIAlertController(
            title: NSLocalizedString("deleteAccount", comment: ""),
            message: NSLocalizedString("areYouSureDeleteAccount", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAccount()
            SceneDelegate.loginUser = false
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(splashVC)
            }
        })
        present(alert, animated: true)
    }
    func promptReview() {
        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    func openUrl(_ url: String) {
        guard let urlToOpen = URL(string: url) else { return }
            
        let safariVC = SFSafariViewController(url: urlToOpen)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }
    
    func showPaywall() {
        if IAPService.shared.isPremiumUser() {
            showAlert(title: NSLocalizedString("info", comment: ""), message: NSLocalizedString("alreadyHavePremium", comment: ""))
            return
        }
        // Use the UIKit paywall implementation
        let paywallVC = RevenueCatPaywallViewController()
        paywallVC.modalPresentationStyle = .fullScreen
        present(paywallVC, animated: true)
    }
    
    func restorePurchases() {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: NSLocalizedString("restoringPurchases", comment: ""), preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        // Attempt to restore purchases
        viewModel.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                // Dismiss loading indicator
                loadingAlert.dismiss(animated: true) {
                    // Show result
                    switch result {
                    case .success:
                        if self?.iapService.isPremiumUser() == true {
                            self?.showAlert(title: NSLocalizedString("success", comment: ""), message: NSLocalizedString("restoreSuccess", comment: ""))
                        } else {
                            self?.showAlert(title: NSLocalizedString("info", comment: ""), message: NSLocalizedString("noActiveSubscription", comment: ""))
                        }
                    case .failure(let error):
                        self?.showAlert(title: NSLocalizedString("error", comment: ""), message: "\(NSLocalizedString("error", comment: "")): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateSubscriptionStatus() {
        let status = viewModel.getSubscriptionStatusText()
        subscriptionStatusLabel?.text = status
    }
}
    
// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        didSelect(item: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: -  UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].items.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let section = viewModel.sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        cell.tintColor = .label
        cell.textLabel?.text = item.title
        cell.textLabel?.textAlignment = .natural
        cell.textLabel?.textColor = .label
        cell.imageView?.image = UIImage(systemName: item.iconName)
        
        switch item.type {
        case .theme:
            let segmentControl = UISegmentedControl(items: [NSLocalizedString("auto", comment: ""), NSLocalizedString("light", comment: ""),NSLocalizedString("dark", comment: "")])
            segmentControl.selectedSegmentIndex = viewModel.fetchThemeMode()
            segmentControl.addTarget(self, action: #selector(didChangeTheme(_:)), for: .valueChanged)
            cell.accessoryView = segmentControl
        case .notification:
            let switcher = UISwitch()
            notificationSwitch = switcher
            viewModel.fetchNotificationStatus{switcher.isOn = $0 }
            switcher.addTarget(self, action: #selector(didToggleNotification(_:)), for: .valueChanged)
            cell.accessoryView = switcher
        case .subscription:
            // Subscription status label
            let label = UILabel()
            label.font = .systemFont(ofSize: 13)
            label.textColor = .secondaryLabel
            label.text = viewModel.getSubscriptionStatusText()
            subscriptionStatusLabel = label
            
            cell.accessoryView = label
            cell.accessoryType = .disclosureIndicator
        case .deleteAccount, .rateApp, .privacyPolicy, .termsOfUse, .restorePurchases:
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    
} 

extension SettingsViewController: SettingsViewControllerProtocol {
    func updateSwitchValue(_ value: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.notificationSwitch?.isOn = value
        }
    }
    
    func updateSubscriptionStatusLabel(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.subscriptionStatusLabel?.text = text
        }
    }
    
    func openAppSettings() {
            if let settingsURL = URL(
                string: UIApplication.openSettingsURLString
            ),UIApplication.shared
                .canOpenURL(settingsURL){ DispatchQueue.main.async {
                    UIApplication.shared.open(
                        settingsURL,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
                
        }
}
