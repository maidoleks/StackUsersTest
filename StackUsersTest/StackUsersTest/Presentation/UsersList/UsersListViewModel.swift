//
//  UsersListViewModel.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

@MainActor @Observable
final class UsersListViewModel {
    // MARK: - Dependencies
    
    private let usersRepository: UsersRepository
    
    // MARK: - Properties
    
    private(set) var state: State = .loading
    private(set) var isLoading:Bool = false
    
    private var users: [User] = []
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Init
    
    init(usersRepository: UsersRepository) {
        self.usersRepository = usersRepository
    }
    
    // MARK: - Public methods
    
    func refresh() {
        currentPage = 1
        users = []
        hasMorePages = true
        state = .loading
        fetchNextPage() // TODO: check if we need to cancel previous task
    }
    
    func loadNextPageIfNeeded() {
        guard !isLoading, hasMorePages else { return }
        fetchNextPage()
    }

    // MARK: - Private methods

    private func fetchNextPage() {
        isLoading = true

        Task {
            do {
                let result = try await usersRepository.fetchUsers(
                    page: currentPage,
                    pageSize: AppConstants.pageSize
                )
                users.append(contentsOf: result.users)
                currentPage += 1
                let hasMoreFromResponse = result.hasMore
                hasMorePages = hasMoreFromResponse && users.count < AppConstants.maxAllowedUsers
                isLoading = false
                updateState(users: users)
            } catch {
                isLoading = false
                updateState(error: error)
            }
        }
    }
    
    private func updateState(users: [User] = [], error: Error? = nil) {
        if let error, users.isEmpty {
            // TODO: check if we need to show some error if not the first page failed to load
            state = .error(error.localizedDescription)
            return
        }
        
        state = .loaded(users)
    }
}


// MARK: - State

extension UsersListViewModel {
    enum State: Equatable {
        case loading
        case loaded([User])
        case error(String)
    }
}
