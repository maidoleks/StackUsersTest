//
//  UsersRepository.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

protocol UsersRepository {
    func fetchUsers(page: Int, pageSize: Int) async throws -> UsersPage
}
