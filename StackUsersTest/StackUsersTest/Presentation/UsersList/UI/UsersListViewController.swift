//
//  UsersListViewController.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import UIKit
import Observation

final class UsersListViewController: UIViewController {
    // MARK: - Dependencies
    
    private let viewModel: UsersListViewModel
    
    // MARK: - UI
    
    private let tableView = UITableView()
    
    private let footerLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56)
        return indicator
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // Error state is optional
    private var errorView: UIView?
    private var errorLabel: UILabel?
    
    private var items: [UserListItem] = []

    // MARK: - Init

    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("This VC doesn't support load from nib") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupRefreshControl()
        startObserving()
        viewModel.refresh()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UsersListCell.self, forCellReuseIdentifier: UsersListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = footerLoadingIndicator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 74

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupLoadingIndicator() {
        guard loadingIndicator.superview == nil else { return }
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupErrorView(message: String) {
        // update message if error view exists
        if let label = errorLabel {
            label.text = message
            return
        }
        
        // if errorView doesn't exist - create new one
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onRetryTap), for: .touchUpInside)
        
        container.addSubview(label)
        container.addSubview(button)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        errorView = container
        errorLabel = label
    }
    
    private func removeErrorView() {
        errorView?.removeFromSuperview()
        errorView = nil
        errorLabel = nil
    }
    private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(onRefreshAction), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    // MARK: - Actions
    
    @objc private func onRetryTap() {
        viewModel.refresh()
    }
    
    @objc private func onRefreshAction() {
        viewModel.refresh()
    }
    
    // MARK: - Observation

    private func startObserving() {
        withObservationTracking {
            applyState(viewModel.state, isAdditionalLoading: viewModel.isLoading)
        } onChange: { [weak self] in
            DispatchQueue.main.async { self?.startObserving() }
        }
    }

    private func applyState(_ state: UsersListViewModel.State, isAdditionalLoading: Bool) {
        switch state {
        case .loading:
            setupLoadingIndicator()
            tableView.isHidden = true
            removeErrorView()
            loadingIndicator.startAnimating()
            tableView.refreshControl?.endRefreshing()

        case .loaded(let newItems):
            updateItems(with: newItems)
            tableView.isHidden = false
            removeErrorView()
            loadingIndicator.stopAnimating()
            tableView.refreshControl?.endRefreshing()

        case .error(let message):
            setupErrorView(message: message)
            tableView.isHidden = true
            loadingIndicator.stopAnimating()
            tableView.refreshControl?.endRefreshing()
        }

        isAdditionalLoading ? footerLoadingIndicator.startAnimating() : footerLoadingIndicator.stopAnimating()
    }
    
    private func updateItems(with newItems: [UserListItem]) {
        let oldCount = items.count
        let newCount = newItems.count
        
        // if it's a first load - just reload
        if oldCount == 0 {
            items = newItems
            tableView.reloadData()
            return
        }
        
        // Do not reload entire table if it's additional page has been loaded
        if newCount > oldCount {
            items = newItems
            let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: newIndexPaths, with: .none)
            }
        } else {
            // if count is the same - then it's a refresh of following statuses
            updateFollowStatusesIfNeeded(old: items, new: newItems)
        }
    }
    
    private func updateFollowStatusesIfNeeded(old: [UserListItem], new: [UserListItem]) {
        guard old.count == new.count else { return }
        
        let changedIndexPaths = zip(old, new).enumerated().compactMap { index, items -> IndexPath? in
            items.0.isFollowed != items.1.isFollowed ? IndexPath(row: index, section: 0) : nil
        }
        
        guard !changedIndexPaths.isEmpty else { return }
        items = new
        tableView.reloadRows(at: changedIndexPaths, with: .none)
    }
}

// MARK: - UITableViewDataSource

extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UsersListCell.reuseIdentifier,
            for: indexPath
        ) as! UsersListCell
        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.toggleFollow = { [weak self] in
            self?.viewModel.toggleFollow(for: item.user.id)
        }
        return cell
    }
}


// MARK: - UITableViewDelegate

extension UsersListViewController: UITableViewDelegate {
    func tableViewWillDisplayFooter(_ tableView: UITableView) {
        viewModel.loadNextPageIfNeeded()
    }
}
