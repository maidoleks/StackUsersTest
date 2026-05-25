//
//  AppCoordinator.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    
    let navigationController: UINavigationController
    private let window: UIWindow
    
    // MARK: - Init
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    // MARK: - Coordinator
    
    func start() {
        let viewController = makeUsersListViewController()
        navigationController.setViewControllers([viewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

    }
    
    // MARK: - Potential future Factory
    
    private func makeUsersListViewController() -> UsersListViewController {
        // could be moved to services container in future
        let apiClient = URLSessionAPIClient()
        let usersRepository = AppUsersRepository(apiClient: apiClient)
        let followService = DefaultsFollowService()
        
        let viewModel = UsersListViewModel(usersRepository: usersRepository, followService: followService)
        let viewController = UsersListViewController(viewModel: viewModel)
        viewController.title = "Top Users"
        return viewController
    }
}
