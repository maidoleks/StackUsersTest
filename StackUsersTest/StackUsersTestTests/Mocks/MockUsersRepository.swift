//
//  MockUsersRepository.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 25/05/2026.
//


@testable import StackUsersTest

final class MockUsersRepository: UsersRepository {
    var result: Result<UsersPage, Error> = .success(UsersPage(users: [], hasMore: false))
    private(set) var fetchCallCount = 0
    private(set) var lastRequestedPage: Int?

    func fetchUsers(page: Int, pageSize: Int) async throws -> UsersPage {
        fetchCallCount += 1
        lastRequestedPage = page
        return try result.get()
    }
}
