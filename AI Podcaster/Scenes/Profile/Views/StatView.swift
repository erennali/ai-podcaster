import UIKit
import SnapKit

class StatView: UIView {
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "headphones")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    init(title: String, value: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        valueLabel.text = value
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - Public Methods
    func updateValue(_ value: String) {
        valueLabel.text = value
    }
} 