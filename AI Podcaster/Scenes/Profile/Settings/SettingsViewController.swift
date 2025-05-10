import UIKit
import StoreKit
import SafariServices

final class SettingsViewController: UIViewController {
    
    
    private let viewModel: SettingsViewModel
    private let themeKey = "selectedTheme"
    
    // MARK: Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
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
            openUrl("https://google.com")
        default : break
        }
    }
    func deleteAccount() {
        let splashVC = SplashViewController()
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
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
            let segmentControl = UISegmentedControl(items: ["Auto", "Light", "Dark"])
            segmentControl.selectedSegmentIndex = viewModel.fetchThemeMode()
            segmentControl.addTarget(self, action: #selector(didChangeTheme(_:)), for: .valueChanged)
            cell.accessoryView = segmentControl
        case .notification:
            let switchControl = UISwitch()
            viewModel.fetchNotificationStatus{switchControl.isOn = $0 }
            switchControl.addTarget(self, action: #selector(didToggleNotification(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
        case .deleteAccount:
            cell.accessoryType = .disclosureIndicator
        case .rateApp, .privacyPolicy, .termsOfUse:
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    
} 

