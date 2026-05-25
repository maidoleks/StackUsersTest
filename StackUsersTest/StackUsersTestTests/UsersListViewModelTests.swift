//
//  UsersListViewModelTests.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 25/05/2026.
//


import XCTest
@testable import StackUsersTest

@MainActor
final class UsersListViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeUsers(count: Int, idOffset: Int = 0) -> [User] {
        (1...max(1, count)).map {
            User(id: $0 + idOffset, displayName: "User \($0 + idOffset)", reputation: $0 * 100, profileImageURL: nil)
        }
    }

    private func makeSUT(
        repoResult: Result<UsersPage, Error> = .success(UsersPage(users: [], hasMore: false))
    ) -> (viewModel: UsersListViewModel, repo: MockUsersRepository, store: MockFollowService) {
        let repo = MockUsersRepository()
        repo.result = repoResult
        let followService = MockFollowService()
        return (UsersListViewModel(usersRepository: repo, followService: followService), repo, followService)
    }

    private func flush() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    // MARK: - Initial state

    func testInitialStateIsLoading() {
        let (sut, _, _) = makeSUT()
        XCTAssertEqual(sut.state, .loading)
    }

    func testIsLoadingIsFalseInitially() {
        let (sut, _, _) = makeSUT()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Successful load

    func testLoadTransitionsToLoadedState() async {
        let users = makeUsers(count: 5)
        let (sut, repo, _) = makeSUT(repoResult: .success(UsersPage(users: users, hasMore: false)))

        sut.refresh()
        await flush()

        XCTAssertEqual(repo.fetchCallCount, 1)
        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, 5)
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
    }

    func testLoadedItemsReflectFollowState() async {
        let users = makeUsers(count: 2)
        let repo = MockUsersRepository()
        repo.result = .success(UsersPage(users: users, hasMore: false))
        let serv = MockFollowService()
        serv.follow(userId: 1)
        let sut = UsersListViewModel(usersRepository: repo, followService: serv)

        sut.refresh()
        await flush()

        if case .loaded(let items) = sut.state {
            XCTAssertTrue(items[0].isFollowed)
            XCTAssertFalse(items[1].isFollowed)
        } else {
            XCTFail("Expected .loaded state")
        }
    }

    // MARK: - Error handling

    func testShowsErrorStateWhenFetchFailsOnEmptyList() async {
        struct Failure: Error {}
        let (sut, _, _) = makeSUT(repoResult: .failure(Failure()))

        sut.refresh()
        await flush()

        if case .error = sut.state { } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
    }

    func testKeepsLoadedItemsWhenPaginationFails() async {
        let repo = MockUsersRepository()
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())

        repo.result = .success(UsersPage(users: makeUsers(count: AppConstants.pageSize), hasMore: true))
        sut.refresh()
        await flush()

        struct Failure: Error {}
        repo.result = .failure(Failure())
        sut.loadNextPageIfNeeded()
        await flush()

        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, AppConstants.pageSize)
        } else {
            XCTFail("Expected .loaded state to be preserved on pagination failure")
        }
    }

    // MARK: - Pagination

    func testPaginationAppendsNextPage() async {
        let repo = MockUsersRepository()
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())
        sut.maxAllowedUsers = 25
        repo.result = .success(UsersPage(users: makeUsers(count: AppConstants.pageSize), hasMore: true))
        sut.refresh()
        await flush()

        repo.result = .success(UsersPage(users: makeUsers(count: 5, idOffset: 100), hasMore: false))
        sut.loadNextPageIfNeeded()
        await flush()

        XCTAssertEqual(repo.fetchCallCount, 2)
        XCTAssertEqual(repo.lastRequestedPage, 2)
        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, AppConstants.pageSize + 5)
        } else {
            XCTFail("Expected .loaded state after pagination")
        }
    }

    func testStopsPaginationWhenHasMoreIsFalse() async {
        let repo = MockUsersRepository()
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())

        repo.result = .success(UsersPage(users: makeUsers(count: 5), hasMore: false))
        sut.refresh()
        await flush()

        let countBefore = repo.fetchCallCount
        sut.loadNextPageIfNeeded()
        await flush()

        XCTAssertEqual(repo.fetchCallCount, countBefore)
    }

    func testStopsPaginationAtMaxLoadedUsers() async {
        let repo = MockUsersRepository()
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())

        repo.result = .success(UsersPage(users: makeUsers(count: AppConstants.maxAllowedUsers), hasMore: true))
        sut.refresh()
        await flush()

        let countBefore = repo.fetchCallCount
        sut.loadNextPageIfNeeded()
        await flush()

        XCTAssertEqual(repo.fetchCallCount, countBefore)
    }

    func testPreventsDuplicateConcurrentRequests() async {
        let repo = MockUsersRepository()
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())

        repo.result = .success(UsersPage(users: makeUsers(count: AppConstants.pageSize), hasMore: true))
        sut.refresh()
        sut.loadNextPageIfNeeded()
        sut.loadNextPageIfNeeded()
        sut.loadNextPageIfNeeded()
        await flush()

        XCTAssertEqual(repo.fetchCallCount, 1)
    }

    // MARK: - Follow / unfollow

    func testToggleFollowFollowsUser() async {
        let repo = MockUsersRepository()
        repo.result = .success(UsersPage(users: makeUsers(count: 1), hasMore: false))
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())

        sut.refresh()
        await flush()

        sut.toggleFollow(for: 1)

        if case .loaded(let items) = sut.state {
            XCTAssertTrue(items[0].isFollowed)
        } else {
            XCTFail("Expected .loaded state")
        }
    }

    func testToggleFollowTwiceRestoresUnfollowedState() async {
        let repo = MockUsersRepository()
        repo.result = .success(UsersPage(users: makeUsers(count: 1), hasMore: false))
        let sut = UsersListViewModel(usersRepository: repo, followService: MockFollowService())

        sut.refresh()
        await flush()

        sut.toggleFollow(for: 1)
        sut.toggleFollow(for: 1)

        if case .loaded(let items) = sut.state {
            XCTAssertFalse(items[0].isFollowed)
        } else {
            XCTFail("Expected .loaded state")
        }
    }
}
