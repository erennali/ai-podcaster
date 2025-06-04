//
//  PodcastSearchComponent.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit

protocol PodcastSearchComponentDelegate: AnyObject {
    func didSelectPodcast(_ podcast: Podcast)
    func didUpdateSearchResults(_ podcasts: [Podcast])
}

final class PodcastSearchComponent: UIView {
    
    // MARK: - Properties
    private let viewModel: SearchViewModel
    weak var delegate: PodcastSearchComponentDelegate?
    
    private var isSearching: Bool = false {
        didSet {
            updateVisibility()
        }
    }
    
    // MARK: - UI Components
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = NSLocalizedString("searchPodcasts", comment: "")
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    private lazy var searchResultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PodcastsCell.self, forCellReuseIdentifier: PodcastsCell.identifier)
        tableView.rowHeight = 180
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("noPodcastsFound", comment: "")
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: SearchViewModel = SearchViewModel()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func getSearchController() -> UISearchController {
        return searchController
    }
    
    func clearSearch() {
        searchController.searchBar.text = ""
        isSearching = false
        viewModel.searchPodcasts(with: "")
    }
}

// MARK: - Private Methods
private extension PodcastSearchComponent {
    
    func setupView() {
        backgroundColor = .clear
        addViews()
        configureLayout()
        updateVisibility()
    }
    
    func setupViewModel() {
        viewModel.delegate = self
    }
    
    func addViews() {
        addSubview(searchResultsTableView)
        addSubview(emptyStateLabel)
        addSubview(loadingIndicator)
    }
    
    func configureLayout() {
        searchResultsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func updateVisibility() {
        if isSearching {
            if viewModel.searchResults.isEmpty {
                searchResultsTableView.isHidden = true
                emptyStateLabel.isHidden = false
            } else {
                searchResultsTableView.isHidden = false
                emptyStateLabel.isHidden = true
            }
        } else {
            searchResultsTableView.isHidden = true
            emptyStateLabel.isHidden = true
        }
    }
}

// MARK: - UISearchBarDelegate
extension PodcastSearchComponent: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        
        if searchText.isEmpty {
            delegate?.didUpdateSearchResults([])
        } else {
            loadingIndicator.startAnimating()
            viewModel.searchPodcasts(with: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text else { return }
        
        if !searchText.isEmpty {
            loadingIndicator.startAnimating()
            viewModel.searchPodcasts(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        delegate?.didUpdateSearchResults([])
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
            isSearching = false
            delegate?.didUpdateSearchResults([])
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PodcastSearchComponent: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastsCell.identifier, for: indexPath) as! PodcastsCell
        cell.configure(with: viewModel.searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPodcast = viewModel.searchResults[indexPath.row]
        delegate?.didSelectPodcast(selectedPodcast)
    }
}

// MARK: - SearchViewModelDelegate
extension PodcastSearchComponent: SearchViewModelDelegate {
    
    func didUpdateSearchResults() {
        loadingIndicator.stopAnimating()
        searchResultsTableView.reloadData()
        updateVisibility()
        delegate?.didUpdateSearchResults(viewModel.searchResults)
    }
    
    func didFailToSearch(with error: String) {
        loadingIndicator.stopAnimating()
        emptyStateLabel.text = "\(NSLocalizedString("error", comment: "")): \(error)"
        emptyStateLabel.isHidden = false
        searchResultsTableView.isHidden = true
    }
} 
