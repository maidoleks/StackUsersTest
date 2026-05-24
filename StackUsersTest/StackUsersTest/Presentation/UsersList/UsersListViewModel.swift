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
    private let followService: FollowService
    
    // MARK: - Properties
    
    // public for testing
    var pageSize: Int = AppConstants.pageSize
    var maxAllowedUsers: Int = AppConstants.maxAllowedUsers
    
    private(set) var state: State = .loading
    private(set) var isLoading:Bool = false
    
    private var users: [User] = []
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Init
    
    init(usersRepository: UsersRepository, followService: FollowService) {
        self.usersRepository = usersRepository
        self.followService = followService
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
    
    func toggleFollow(for userId: Int) {
        if followService.isFollowed(userId: userId) {
            followService.unfollow(userId: userId)
        } else {
            followService.follow(userId: userId)
        }
        updateState()
    }

    // MARK: - Private methods

    private func fetchNextPage() {
        isLoading = true

        Task {
            do {
                let result = try await usersRepository.fetchUsers(
                    page: currentPage,
                    pageSize: pageSize
                )
                users.append(contentsOf: result.users)
                currentPage += 1
                let hasMoreFromResponse = result.hasMore
                hasMorePages = hasMoreFromResponse && users.count < maxAllowedUsers
                isLoading = false
                updateState()
            } catch {
                isLoading = false
                updateState(error)
            }
        }
    }
    
    private func updateState(_ error: Error? = nil) {
        if let error, users.isEmpty {
            // TODO: check if we need to show some error if not the first page failed to load
            state = .error(error.localizedDescription)
            return
        }
        let items = users.map {
            UserListItem(user: $0, isFollowed: followService.isFollowed(userId: $0.id))
        }
        state = .loaded(items)
    }
}


// MARK: - State

extension UsersListViewModel {
    enum State: Equatable {
        case loading
        case loaded([UserListItem])
        case error(String)
    }
}
