import UIKit
import RevenueCat
import SnapKit

final class PaywallViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = PaywallViewModel()
    
    // MARK: - UI Components
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Premium Üyelik"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Daha fazla içerik ve özelliklerle podcast deneyiminizi geliştirin"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var featuresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        
        // Add feature items
        let features = [
            "Sınırsız podcast oluşturma",
            "Reklamsız deneyim",
            "Yüksek kaliteli sesler",
            "Öncelikli destek"
        ]
        
        for feature in features {
            let featureView = FeatureView(text: feature)
            stackView.addArrangedSubview(featureView)
        }
        
        return stackView
    }()
    
    private lazy var packagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Satın Alımları Geri Yükle", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        configureView()
        viewModel.fetchOfferings()
    }
    
    // MARK: - Setup
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        addViews()
        configureLayout()
    }
    
    private func addViews() {
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(featuresStackView)
        view.addSubview(packagesStackView)
        view.addSubview(restoreButton)
        view.addSubview(activityIndicator)
    }
    
    private func configureLayout() {
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        packagesStackView.snp.makeConstraints { make in
            make.top.equalTo(featuresStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(packagesStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func createPackageButton(for package: Package) -> UIButton {
        let button = UIButton(type: .system)
        
        // Get formatted info
        let price = viewModel.getFormattedPrice(for: package)
        let duration = viewModel.getFormattedDuration(for: package)
        
        // Create attribute string for title
        let titleString = NSMutableAttributedString()
        
        // Add duration with bold font
        let durationAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        titleString.append(NSAttributedString(string: duration, attributes: durationAttributes))
        
        // Add price with regular font
        let priceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        titleString.append(NSAttributedString(string: " - \(price)", attributes: priceAttributes))
        
        button.setAttributedTitle(titleString, for: .normal)
        
        // Style the button
        button.backgroundColor = UIColor(named: "anaTemaRenk") ?? .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Tag the button with the index of the package for identification
        if let index = viewModel.availablePackages.firstIndex(where: { $0.identifier == package.identifier }) {
            button.tag = index
        }
        
        // Add action
        button.addTarget(self, action: #selector(packageButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func packageButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.availablePackages.count else { return }
        
        let selectedPackage = viewModel.availablePackages[index]
        viewModel.purchase(package: selectedPackage)
    }
    
    @objc private func restoreButtonTapped() {
        viewModel.restorePurchases()
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PaywallViewModelDelegate
extension PaywallViewController: PaywallViewModelDelegate {
    func packagesDidLoad() {
        DispatchQueue.main.async { [weak self] in
            self?.updatePackagesUI()
        }
    }
    
    func purchaseDidSucceed() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: "Başarılı", message: "Satın alma işlemi başarıyla tamamlandı. Premium özellikler aktif edildi.")
            self?.dismiss(animated: true)
        }
    }
    
    func purchaseDidFail(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: "Hata", message: "Satın alma işlemi başarısız oldu: \(error.localizedDescription)")
        }
    }
    
    func purchaseWasCancelled() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: "İptal Edildi", message: "Satın alma işlemi iptal edildi.")
        }
    }
    
    func startLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func stopLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func restoreDidSucceed() {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: "Başarılı", message: "Satın alımlar başarıyla geri yüklendi.")
            self?.dismiss(animated: true)
        }
    }
    
    func restoreDidFail(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: "Hata", message: "Satın alımlar geri yüklenirken bir hata oluştu: \(error.localizedDescription)")
        }
    }
    
    func offeringsLoadFailed(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            // For development, we can continue with mock data
            #if DEBUG
            if self?.viewModel.hasMockPackages == true {
                self?.updatePackagesUI()
                return
            }
            #endif
            
            // Show a user-friendly error message
            self?.showAlert(title: "Paketler Yüklenemedi", 
                           message: "Şu anda paketler yüklenemiyor. Lütfen daha sonra tekrar deneyin.")
        }
    }
    
    // MARK: - Debug Helpers
    #if DEBUG
    private func updatePackagesUI() {
        // Clear existing package views
        packagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if viewModel.hasMockPackages {
            // Add mock package buttons for development testing
            let monthlyButton = createMockPackageButton(title: "Aylık - ₺29.99", tag: 0)
            let lifetimeButton = createMockPackageButton(title: "Sınırsız - ₺199.99", tag: 1)
            
            packagesStackView.addArrangedSubview(monthlyButton)
            packagesStackView.addArrangedSubview(lifetimeButton)
            return
        }
        
        // Normal package display logic
        for package in viewModel.availablePackages {
            let packageButton = createPackageButton(for: package)
            packagesStackView.addArrangedSubview(packageButton)
        }
    }
    
    private func createMockPackageButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        
        // Create attribute string for title
        let titleString = NSMutableAttributedString()
        
        // Use the same styling as the real buttons
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        titleString.append(NSAttributedString(string: title, attributes: attributes))
        
        button.setAttributedTitle(titleString, for: .normal)
        
        // Style the button
        button.backgroundColor = UIColor(named: "anaTemaRenk") ?? .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Tag the button for identification
        button.tag = tag
        
        // Add action
        button.addTarget(self, action: #selector(mockPackageButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func mockPackageButtonTapped(_ sender: UIButton) {
        // In development mode, show a message about mock functionality
        showAlert(title: "Geliştirme Modu", 
                 message: "RevenueCat yapılandırması tamamlanana kadar gerçek satın alma işlemleri yapılamaz.")
    }
    #else
    private func updatePackagesUI() {
        // Clear existing package views
        packagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Normal package display logic
        for package in viewModel.availablePackages {
            let packageButton = createPackageButton(for: package)
            packagesStackView.addArrangedSubview(packageButton)
        }
    }
    #endif
}

// MARK: - Helper Views
class FeatureView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = UIColor(named: "anaTemaRenk") ?? .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    init(text: String) {
        super.init(frame: .zero)
        textLabel.text = text
        
        addSubview(iconImageView)
        addSubview(textLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.bottom.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 