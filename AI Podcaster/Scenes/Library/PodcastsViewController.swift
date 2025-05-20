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

}

private extension PodcastsViewController {
    
    func configureView() {
        view.backgroundColor = .systemBackground
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
        }
        
        
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
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedArticle = viewModel.podcasts[indexPath.row]
//        let detailsVM = DetailsViewModel(article: selectedArticle)
//        let detailsViewController = DetailsViewController(viewModel: detailsVM)
//        navigationController?.pushViewController(detailsViewController, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
}
