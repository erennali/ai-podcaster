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
    private lazy var scrollView = createScrollView()
    private lazy var contentView = UIView()
    private lazy var headerView = createHeaderView()
    private lazy var titleLabel = createLabel(text: NSLocalizedString("filterSort", comment: ""), fontSize: 20, weight: .bold)
    
    private lazy var resetButton = createButton(
        title: NSLocalizedString("reset", comment: ""),
        color: .systemRed,
        bgColor: .systemRed.withAlphaComponent(0.1),
        action: #selector(resetButtonTapped)
    )
    
    private lazy var doneButton = createButton(
        title: NSLocalizedString("done", comment: ""),
        color: .white,
        bgColor: .systemIndigo,
        action: #selector(doneButtonTapped),
        withShadow: true
    )
    
    // Filter Sections
    private lazy var sortSectionView = createSectionView(title: NSLocalizedString("sortBy", comment: ""))
    private lazy var styleSectionView = createSectionView(title: NSLocalizedString("style", comment: ""))
    private lazy var languageSectionView = createSectionView(title: NSLocalizedString("language", comment: ""))
    private lazy var durationSectionView = createSectionView(title: NSLocalizedString("duration", comment: ""))
    
    // Controls
    private lazy var sortSegmentedControl = createSegmentedControl(
        items: [NSLocalizedString("date", comment: ""), NSLocalizedString("title", comment: "")],
        action: #selector(sortTypeChanged)
    )
    
    private lazy var sortOrderSegmentedControl = createSegmentedControl(
        items: [NSLocalizedString("newest", comment: ""), NSLocalizedString("oldest", comment: "")],
        action: #selector(sortOrderChanged)
    )
    
    private lazy var styleStackView = createVerticalStackView()
    private lazy var languageStackView = createVerticalStackView()
    private lazy var durationStackView = createVerticalStackView()
    
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
        configureView()
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
    
    private func setupViewModel() {
        filterViewModel.delegate = self
    }
}

// MARK: - UI Setup
private extension PodcastFilterComponent {
    
    func configureView() {
        view.backgroundColor = .systemBackground
        addViews()
        configureLayout()
    }
    
    func addViews() {
        // Header Section
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(resetButton)
        headerView.addSubview(doneButton)
        
        // Main Content
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
        // Header layout
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in make.center.equalToSuperview() }
        resetButton.snp.makeConstraints { make in make.leading.equalToSuperview().inset(16); make.centerY.equalToSuperview() }
        doneButton.snp.makeConstraints { make in make.trailing.equalToSuperview().inset(16); make.centerY.equalToSuperview() }
        
        // Scroll view layout
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Content sections layout
        configureSortSectionLayout()
        configureStyleSectionLayout()
        configureLanguageSectionLayout()
        configureDurationSectionLayout()
    }
}

// MARK: - Section Layout
private extension PodcastFilterComponent {
    func configureSortSectionLayout() {
        // Sort section
        sortSectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Sort controls
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
    }
    
    func configureStyleSectionLayout() {
        configureFilterSectionLayout(
            sectionView: styleSectionView,
            stackView: styleStackView,
            previousView: sortSectionView
        )
    }
    
    func configureLanguageSectionLayout() {
        configureFilterSectionLayout(
            sectionView: languageSectionView,
            stackView: languageStackView,
            previousView: styleSectionView
        )
    }
    
    func configureDurationSectionLayout() {
        configureFilterSectionLayout(
            sectionView: durationSectionView,
            stackView: durationStackView,
            previousView: languageSectionView,
            isLastSection: true
        )
    }
    
    func configureFilterSectionLayout(
        sectionView: UIView, 
        stackView: UIStackView, 
        previousView: UIView, 
        isLastSection: Bool = false
    ) {
        let makeConstraints: (ConstraintMaker) -> Void = { make in
            make.top.equalTo(previousView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            if isLastSection {
                make.bottom.equalToSuperview().inset(16)
            }
        }
        
        sectionView.snp.makeConstraints(makeConstraints)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func createSectionView(title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        
        let titleLabel = createLabel(text: title, fontSize: 18, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .label
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in make.top.leading.equalToSuperview().inset(16) }
        
        return containerView
    }
}

// MARK: - UI Updates
private extension PodcastFilterComponent {
    func updateUI() {
        // Update sort controls based on current configuration
        let configuration = filterViewModel.currentConfiguration
        let sortType = configuration.sortType
        
        // 1. Update sort type segmented control (Date/Title)
        sortSegmentedControl.selectedSegmentIndex = filterViewModel.isSortTypeDate ? 0 : 1
        
        // 2. Update sort order segmented control with appropriate titles and selection
        sortOrderSegmentedControl.removeAllSegments()
        let segmentTitles = filterViewModel.getSortSegmentTitles()
        
        for (index, title) in segmentTitles.enumerated() {
            sortOrderSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        
        // 3. Set selected segment based on current sort order
        switch sortType {
        case .date(let order):
            sortOrderSegmentedControl.selectedSegmentIndex = order == .newest ? 0 : 1
        case .title(let order):
            sortOrderSegmentedControl.selectedSegmentIndex = order == .aToZ ? 0 : 1
        }
        
        // 4. Update reset button state based on whether filters are active
        resetButton.isEnabled = filterViewModel.hasActiveFilters
        resetButton.alpha = filterViewModel.hasActiveFilters ? 1.0 : 0.5
        
        // 5. Update all filter buttons to reflect current selection state
        refreshFilterButtons()
    }
}

// MARK: - Filter Buttons Creation
private extension PodcastFilterComponent {
    func createFilterButtons(for items: [String], type: FilterType) {
        let stackView = type == .style ? styleStackView : languageStackView
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create a scrollable horizontal layout for the filter buttons
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
        
        // Add buttons to horizontal stack
        for item in items {
            let button = createFilterButton(title: item) { [weak self] in
                switch type {
                case .style:
                    self?.filterViewModel.toggleStyleFilter(item)
                case .language:
                    self?.filterViewModel.toggleLanguageFilter(item)
                }
            }
            
            // Set initial selection state
            let isSelected = type == .style ? 
                filterViewModel.isStyleSelected(item) : 
                filterViewModel.isLanguageSelected(item)
            updateButtonAppearance(button, isSelected: isSelected)
            
            horizontalStackView.addArrangedSubview(button)
        }
        
        // Add the scrollView to the main stackView
        stackView.addArrangedSubview(scrollView)
        
        // Set the height of the scrollView
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    func createDurationButtons() {
        durationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let horizontalContainer = UIStackView()
        horizontalContainer.axis = .horizontal
        horizontalContainer.spacing = 12
        horizontalContainer.distribution = .fillEqually
        
        // Add range buttons
        for range in DurationRange.allRanges {
            let button = createFilterButton(title: range.displayName) { [weak self] in
                guard let self = self else { return }
                let currentRange = self.filterViewModel.currentConfiguration.filterOptions.selectedDurationRange
                let newRange = currentRange == range ? nil : range
                self.filterViewModel.updateDurationFilter(newRange)
                
                // Immediately update UI to change button color
                self.updateUI()
            }
            
            // Set initial selection state
            let isSelected = filterViewModel.isDurationRangeSelected(range)
            updateButtonAppearance(button, isSelected: isSelected)
            
            horizontalContainer.addArrangedSubview(button)
        }
        
        durationStackView.addArrangedSubview(horizontalContainer)
        
        // Add clear button
        let clearButton = createFilterButton(title: NSLocalizedString("clear", comment: ""), isSpecial: true) { [weak self] in
            self?.filterViewModel.updateDurationFilter(nil)
            // Update UI when clear button is pressed
            self?.updateUI()
        }
        durationStackView.addArrangedSubview(clearButton)
        
        // Layout
        horizontalContainer.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        clearButton.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
    }
    
    func createFilterButton(title: String, isSpecial: Bool = false, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Set initial appearance
        if isSpecial {
            button.setTitleColor(.systemRed, for: .normal)
            button.backgroundColor = .systemRed.withAlphaComponent(0.1)
            button.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.2).cgColor
        } else {
            button.setTitleColor(.systemIndigo, for: .normal)
            button.backgroundColor = .secondarySystemBackground
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowOpacity = 0.05
            button.layer.shadowRadius = 2
            button.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        // Common settings
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        
        // Add action
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        // Constraints
        button.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.greaterThanOrEqualTo(80)
        }
        
        return button
    }
}

// MARK: - Button Styling
private extension PodcastFilterComponent {
    func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        button.backgroundColor = isSelected ? .systemIndigo : .secondarySystemBackground
        button.setTitleColor(isSelected ? .white : .systemIndigo, for: .normal)
        button.layer.borderColor = isSelected ? UIColor.systemIndigo.cgColor : UIColor.systemGray4.cgColor
        button.layer.shadowOpacity = isSelected ? 0.15 : 0.05
        button.layer.shadowRadius = isSelected ? 4 : 2
    }
}

// MARK: - Actions
private extension PodcastFilterComponent {
    @objc func sortTypeChanged() {
        let isDate = sortSegmentedControl.selectedSegmentIndex == 0
        filterViewModel.updateSortType(isDate ? .date(.newest) : .title(.aToZ))
    }
    
    @objc func sortOrderChanged() {
        let isDate = sortSegmentedControl.selectedSegmentIndex == 0
        let firstOption = sortOrderSegmentedControl.selectedSegmentIndex == 0
        
        let sortType = isDate 
            ? SortType.date(firstOption ? .newest : .oldest)
            : SortType.title(firstOption ? .aToZ : .zToA)
            
        filterViewModel.updateSortType(sortType)
    }
    
    @objc func resetButtonTapped() {
        filterViewModel.resetToDefault()
    }
    
    @objc func doneButtonTapped() {
        delegate?.didUpdateFilter(configuration: filterViewModel.currentConfiguration)
        dismiss(animated: true)
    }
    
}

// MARK: - Button Refresh
private extension PodcastFilterComponent {
    func refreshFilterButtons() {
        // Update style buttons
        styleStackView.subviews.forEach { subview in
            if let scrollView = subview as? UIScrollView {
                for case let button as UIButton in scrollView.subviews.flatMap({ $0.subviews }) {
                    if let title = button.title(for: .normal) {
                        updateButtonAppearance(button, isSelected: filterViewModel.isStyleSelected(title))
                    }
                }
            }
        }
        
        // Update language buttons
        languageStackView.subviews.forEach { subview in
            if let scrollView = subview as? UIScrollView {
                for case let button as UIButton in scrollView.subviews.flatMap({ $0.subviews }) {
                    if let title = button.title(for: .normal) {
                        updateButtonAppearance(button, isSelected: filterViewModel.isLanguageSelected(title))
                    }
                }
            }
        }
        
        // Update duration buttons
        durationStackView.subviews.forEach { subview in
            if let stackView = subview as? UIStackView {
                for case let button as UIButton in stackView.arrangedSubviews {
                    if let title = button.title(for: .normal), title != NSLocalizedString("clear", comment: "") {
                        if let range = DurationRange.allRanges.first(where: { $0.displayName == title }) {
                            updateButtonAppearance(button, isSelected: filterViewModel.isDurationRangeSelected(range))
                        }
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

// MARK: - Helpers
private extension PodcastFilterComponent {
    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }
    
    func createHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }
    
    func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textAlignment = .center
        return label
    }
    
    func createButton(title: String, color: UIColor, bgColor: UIColor, action: Selector, withShadow: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.baseBackgroundColor = bgColor
            configuration.baseForegroundColor = color
            configuration.cornerStyle = .medium
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            button.configuration = configuration
        } else {
            // iOS 14 ve altında eski yöntemi kullan
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.setTitleColor(color, for: .normal)
            button.backgroundColor = bgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        }
        
        button.layer.cornerRadius = 8
        
        if withShadow {
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.1
            button.layer.shadowRadius = 4
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    func createSegmentedControl(items: [String], action: Selector) -> UISegmentedControl {
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemIndigo
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemIndigo], for: .normal)
        control.addTarget(self, action: action, for: .valueChanged)
        return control
    }
    
    func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }
} 
