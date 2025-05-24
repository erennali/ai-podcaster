//
//  PodcastsViewController.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 27.04.2025.
//

import UIKit
import SnapKit

protocol PodcastsViewControllerProtocol: AnyObject {
    func reloadData()
}

final class PodcastsViewController: UIViewController {

    private let viewModel: PodcastsViewModel
    private lazy var searchComponent = PodcastSearchComponent()
    private var filterComponent: PodcastFilterComponent?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PodcastsCell.self, forCellReuseIdentifier: PodcastsCell.identifier)
        tableView.rowHeight = 180
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    init(viewModel: PodcastsViewModel = PodcastsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        searchComponent.delegate = self
        configureView()
        viewModel.fetchPodcasts()
        
        // Search component başlangıçta gizli olsun
        searchComponent.isHidden = true
        
        // Search controller delegate'i ayarla
        searchComponent.getSearchController().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Her görünüme geldiğinde podcast listesini yenile
        viewModel.fetchPodcasts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

private extension PodcastsViewController {
    
    func configureView() {
        view.backgroundColor = .systemBackground
        
        
        // Search controller'ı navigation bar'a ekle
        navigationItem.searchController = searchComponent.getSearchController()
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Filter button'ı navigation bar'a ekle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        
        addViews()
        configureLayout()
    }
    
    func addViews() {
        view.addSubview(tableView)
        view.addSubview(searchComponent)
    }
    
    func configureLayout() {
        tableView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        searchComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func filterButtonTapped() {
        presentFilterModal()
    }
    
    private func presentFilterModal() {
        let filterViewModel = PodcastFilterViewModel()
        filterComponent = PodcastFilterComponent(filterViewModel: filterViewModel)
        
        guard let filterComponent = filterComponent else { return }
        
        filterComponent.delegate = self
        filterComponent.setupWithPodcasts(viewModel.podcasts)
        
        filterComponent.modalPresentationStyle = .pageSheet
        if let sheet = filterComponent.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(filterComponent, animated: true)
    }
    
    private func updateFilterButtonAppearance() {
        let hasFilters = viewModel.hasActiveFilters
        let image = hasFilters ? 
            UIImage(systemName: "line.3.horizontal.decrease.circle.fill") :
            UIImage(systemName: "line.3.horizontal.decrease.circle")
        
        navigationItem.rightBarButtonItem?.image = image
        navigationItem.rightBarButtonItem?.tintColor = hasFilters ? .systemRed : .systemBlue
    }
}

extension PodcastsViewController: PodcastsViewControllerProtocol {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            // Veri olmadığında bir mesaj göster
            if self.viewModel.podcasts.isEmpty {
                self.showEmptyStateMessage()
            } else {
                self.hideEmptyStateMessage()
            }
            
            // Filter button görünümünü güncelle
            self.updateFilterButtonAppearance()
        }
    }
    
    private func showEmptyStateMessage() {
        let messageLabel = UILabel()
        let message = viewModel.hasActiveFilters ? 
            "No podcasts match your filters.\nTry adjusting your filter settings." :
            "No podcasts yet.\nCreate your first podcast from the Create tab!"
        
        messageLabel.text = message
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        tableView.backgroundView = messageLabel
    }
    
    private func hideEmptyStateMessage() {
        tableView.backgroundView = nil
    }
}

extension PodcastsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastsCell.identifier, for: indexPath) as! PodcastsCell
        cell.configure(with: viewModel.podcasts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPodcast = viewModel.podcasts[indexPath.row]
        let detailsVM = PodcastDetailsViewModel(podcast: selectedPodcast)
        let detailsViewController = PodcastDetailsViewController(viewModel: detailsVM)
        navigationController?.pushViewController(detailsViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchControllerDelegate
extension PodcastsViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.isHidden = true
        searchComponent.isHidden = false
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        tableView.isHidden = false
        searchComponent.isHidden = true
    }
}

// MARK: - PodcastSearchComponentDelegate
extension PodcastsViewController: PodcastSearchComponentDelegate {
    func didSelectPodcast(_ podcast: Podcast) {
        let detailsVM = PodcastDetailsViewModel(podcast: podcast)
        let detailsViewController = PodcastDetailsViewController(viewModel: detailsVM)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func didUpdateSearchResults(_ podcasts: [Podcast]) {
        // Search sonuçları güncellendi - gerekirse ek işlemler yapılabilir
        // Örneğin analytics, logging vb.
    }
}

// MARK: - PodcastsViewModelDelegate
extension PodcastsViewController: PodcastsViewModelDelegate {
    func didUpdatePodcasts() {
        reloadData()
    }
    
    func didShowError(_ error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - PodcastFilterComponentDelegate
extension PodcastsViewController: PodcastFilterComponentDelegate {
    func didUpdateFilter(configuration: PodcastFilterConfiguration) {
        viewModel.updateFilter(configuration: configuration)
    }
}
