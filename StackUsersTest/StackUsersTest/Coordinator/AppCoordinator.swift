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
        
        // test
        Task {
            let api = URLSessionAPIClient()
            let repo = AppUsersRepository(apiClient: api)
            let users = try? await repo.fetchUsers(page: 1, pageSize: 20)
            debugPrint(users)
        }
    }
    
    // MARK: - Coordinator
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
