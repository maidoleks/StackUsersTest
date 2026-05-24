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
            let users: UsersResponseDTO? = try? await api.fetch(from: APIEndpoint.users(page: 1, pageSize: 20).url!)
            debugPrint(users)
        }
    }
    
    // MARK: - Coordinator
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
