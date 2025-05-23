//
//  PodcastFilterComponent.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit

protocol PodcastFilterComponentDelegate: AnyObject {
    func didUpdateFilter(configuration: PodcastFilterConfiguration)
}

final class PodcastFilterComponent: UIViewController {
    
    // MARK: - Properties
    private let filterViewModel: PodcastFilterViewModel
    weak var delegate: PodcastFilterComponentDelegate?
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter & Sort"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .systemRed.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Sort Section
    private lazy var sortSectionView = createSectionView(title: "Sort By")
    private lazy var sortSegmentedControl: UISegmentedControl = {
        let items = ["Date", "Title"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemIndigo
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemIndigo], for: .normal)
        control.addTarget(self, action: #selector(sortTypeChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var sortOrderSegmentedControl: UISegmentedControl = {
        let items = ["Newest First", "Oldest First"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemIndigo
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemIndigo], for: .normal)
        control.addTarget(self, action: #selector(sortOrderChanged), for: .valueChanged)
        return control
    }()
    
    // Style Filter Section
    private lazy var styleSectionView = createSectionView(title: "Style")
    private lazy var styleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // Language Filter Section
    private lazy var languageSectionView = createSectionView(title: "Language")
    private lazy var languageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // Duration Filter Section
    private lazy var durationSectionView = createSectionView(title: "Duration")
    private lazy var durationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Initialization
    init(filterViewModel: PodcastFilterViewModel = PodcastFilterViewModel()) {
        self.filterViewModel = filterViewModel
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
        setupInitialFilters()
        updateUI()
    }
    
    // MARK: - Public Methods
    func setupWithPodcasts(_ podcasts: [Podcast]) {
        filterViewModel.setupWithPodcasts(podcasts)
    }
    
    private func setupInitialFilters() {
        createFilterButtons(for: PodcastOptions.availableStyles, type: .style)
        createFilterButtons(for: PodcastOptions.availableLanguages, type: .language)
        createDurationButtons()
    }
}

// MARK: - Private Methods
private extension PodcastFilterComponent {
    
    func setupView() {
        view.backgroundColor = .systemBackground
        addViews()
        configureLayout()
    }
    
    func setupViewModel() {
        filterViewModel.delegate = self
    }
    
    func addViews() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(resetButton)
        headerView.addSubview(doneButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Sort Section
        contentView.addSubview(sortSectionView)
        sortSectionView.addSubview(sortSegmentedControl)
        sortSectionView.addSubview(sortOrderSegmentedControl)
        
        // Style Section
        contentView.addSubview(styleSectionView)
        styleSectionView.addSubview(styleStackView)
        
        // Language Section
        contentView.addSubview(languageSectionView)
        languageSectionView.addSubview(languageStackView)
        
        // Duration Section
        contentView.addSubview(durationSectionView)
        durationSectionView.addSubview(durationStackView)
    }
    
    func configureLayout() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        resetButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Sort Section Layout
        sortSectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        sortSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        sortOrderSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(sortSegmentedControl.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Style Section Layout
        styleSectionView.snp.makeConstraints { make in
            make.top.equalTo(sortSectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        styleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Language Section Layout
        languageSectionView.snp.makeConstraints { make in
            make.top.equalTo(styleSectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        languageStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Duration Section Layout
        durationSectionView.snp.makeConstraints { make in
            make.top.equalTo(languageSectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        durationStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func createSectionView(title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        return containerView
    }
    
    func updateUI() {
        updateSortUI()
        updateResetButtonState()
        refreshFilterButtons()
    }
    
    func updateSortUI() {
        switch filterViewModel.currentConfiguration.sortType {
        case .date(let order):
            sortSegmentedControl.selectedSegmentIndex = 0
            sortOrderSegmentedControl.removeAllSegments()
            sortOrderSegmentedControl.insertSegment(withTitle: "Newest First", at: 0, animated: false)
            sortOrderSegmentedControl.insertSegment(withTitle: "Oldest First", at: 1, animated: false)
            sortOrderSegmentedControl.selectedSegmentIndex = order == .newest ? 0 : 1
            
        case .title(let order):
            sortSegmentedControl.selectedSegmentIndex = 1
            sortOrderSegmentedControl.removeAllSegments()
            sortOrderSegmentedControl.insertSegment(withTitle: "A to Z", at: 0, animated: false)
            sortOrderSegmentedControl.insertSegment(withTitle: "Z to A", at: 1, animated: false)
            sortOrderSegmentedControl.selectedSegmentIndex = order == .aToZ ? 0 : 1
        }
    }
    
    func updateResetButtonState() {
        resetButton.isEnabled = filterViewModel.hasActiveFilters
        resetButton.alpha = filterViewModel.hasActiveFilters ? 1.0 : 0.5
    }
    
    func createFilterButtons(for items: [String], type: FilterType) {
        let stackView = type == .style ? styleStackView : languageStackView
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Horizontal scroll view container oluştur
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 12
        horizontalStackView.distribution = .fill
        
        scrollView.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // Button'ları horizontal stack'e ekle
        for item in items {
            let button = createFilterButton(title: item, type: type)
            horizontalStackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(scrollView)
        
        // ScrollView height constraint
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    func createFilterButton(title: String, type: FilterType) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        
        // CreaterPodcastsViewController tarzı padding
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // PodcastsCell tarzı compact design
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 2
        
        let isSelected = type == .style ? 
            filterViewModel.isStyleSelected(title) : 
            filterViewModel.isLanguageSelected(title)
        
        updateButtonAppearance(button, isSelected: isSelected)
        
        button.addAction(UIAction { [weak self] _ in
            switch type {
            case .style:
                self?.filterViewModel.toggleStyleFilter(title)
            case .language:
                self?.filterViewModel.toggleLanguageFilter(title)
            }
        }, for: .touchUpInside)
        
        // Button width constraint - minimum width
        button.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.greaterThanOrEqualTo(80)
        }
        
        return button
    }
    
    func createDurationButtons() {
        durationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Duration için vertical layout ama daha compact
        let horizontalContainer = UIStackView()
        horizontalContainer.axis = .horizontal
        horizontalContainer.distribution = .fillEqually
        horizontalContainer.spacing = 12
        
        for range in DurationRange.allRanges {
            let button = createDurationButton(range: range)
            horizontalContainer.addArrangedSubview(button)
        }
        
        durationStackView.addArrangedSubview(horizontalContainer)
        
        // Clear button - daha subtle
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        clearButton.setTitleColor(.systemRed, for: .normal)
        clearButton.backgroundColor = .systemRed.withAlphaComponent(0.1)
        clearButton.layer.cornerRadius = 8
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        clearButton.addAction(UIAction { [weak self] _ in
            self?.filterViewModel.updateDurationFilter(nil)
        }, for: .touchUpInside)
        
        durationStackView.addArrangedSubview(clearButton)
        
        // Container height constraint
        horizontalContainer.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        clearButton.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
    }
    
    func createDurationButton(range: DurationRange) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(range.displayName, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        
        // CreaterPodcastsViewController tarzı shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 2
        
        let isSelected = filterViewModel.isDurationRangeSelected(range)
        updateButtonAppearance(button, isSelected: isSelected)
        
        button.addAction(UIAction { [weak self] _ in
            let currentRange = self?.filterViewModel.currentConfiguration.filterOptions.selectedDurationRange
            let newRange = currentRange == range ? nil : range
            self?.filterViewModel.updateDurationFilter(newRange)
        }, for: .touchUpInside)
        
        return button
    }
    
    func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        // CreaterPodcastsViewController'daki sistemIndigo temasını kullan
        if isSelected {
            button.backgroundColor = .systemIndigo
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.systemIndigo.cgColor
            // Selected state için daha belirgin shadow
            button.layer.shadowOpacity = 0.15
            button.layer.shadowRadius = 4
        } else {
            button.backgroundColor = .secondarySystemBackground
            button.setTitleColor(.systemIndigo, for: .normal)
            button.layer.borderColor = UIColor.systemGray4.cgColor
            // Normal state için subtle shadow
            button.layer.shadowOpacity = 0.05
            button.layer.shadowRadius = 2
        }
    }
    
    @objc func sortTypeChanged() {
        let isDate = sortSegmentedControl.selectedSegmentIndex == 0
        if isDate {
            filterViewModel.updateSortType(.date(.newest))
        } else {
            filterViewModel.updateSortType(.title(.aToZ))
        }
    }
    
    @objc func sortOrderChanged() {
        let isDate = sortSegmentedControl.selectedSegmentIndex == 0
        let firstOption = sortOrderSegmentedControl.selectedSegmentIndex == 0
        
        if isDate {
            filterViewModel.updateSortType(.date(firstOption ? .newest : .oldest))
        } else {
            filterViewModel.updateSortType(.title(firstOption ? .aToZ : .zToA))
        }
    }
    
    @objc func resetButtonTapped() {
        filterViewModel.resetToDefault()
    }
    
    @objc func doneButtonTapped() {
        delegate?.didUpdateFilter(configuration: filterViewModel.currentConfiguration)
        dismiss(animated: true)
    }
    
    func refreshFilterButtons() {
        // Style button'larını güncelle
        for view in styleStackView.arrangedSubviews {
            if let button = view as? UIButton, let title = button.title(for: .normal) {
                let isSelected = filterViewModel.isStyleSelected(title)
                updateButtonAppearance(button, isSelected: isSelected)
            }
        }
        
        // Language button'larını güncelle
        for view in languageStackView.arrangedSubviews {
            if let button = view as? UIButton, let title = button.title(for: .normal) {
                let isSelected = filterViewModel.isLanguageSelected(title)
                updateButtonAppearance(button, isSelected: isSelected)
            }
        }
        
        // Duration button'larını güncelle
        for view in durationStackView.arrangedSubviews {
            if let button = view as? UIButton, let title = button.title(for: .normal) {
                // Duration button için range'i kontrol et
                for range in DurationRange.allRanges {
                    if title == range.displayName {
                        let isSelected = filterViewModel.isDurationRangeSelected(range)
                        updateButtonAppearance(button, isSelected: isSelected)
                        break
                    }
                }
            }
        }
    }
}

enum FilterType {
    case style
    case language
}

// MARK: - PodcastFilterViewModelDelegate
extension PodcastFilterComponent: PodcastFilterViewModelDelegate {
    func didUpdateConfiguration(_ configuration: PodcastFilterConfiguration) {
        updateUI()
        delegate?.didUpdateFilter(configuration: configuration)
    }
    
    func didUpdateAvailableOptions(styles: [String], languages: [String]) {
        createFilterButtons(for: styles, type: .style)
        createFilterButtons(for: languages, type: .language)
        createDurationButtons()
    }
} 