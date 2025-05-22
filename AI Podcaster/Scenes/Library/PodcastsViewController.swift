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
        configureView()
        viewModel.fetchPodcasts()
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
        title = "My Podcasts"
        addViews()
        configureLayout()
    }
    
    func addViews() {
        view.addSubview(tableView)
    }
    
    func configureLayout() {
        tableView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
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
        }
    }
    
    private func showEmptyStateMessage() {
        let messageLabel = UILabel()
        messageLabel.text = "No podcasts yet.\nCreate your first podcast from the Create tab!"
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
