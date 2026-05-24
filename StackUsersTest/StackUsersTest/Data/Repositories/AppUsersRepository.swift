//
//  AppUsersRepository.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

final class AppUsersRepository: UsersRepository {
    // MARK: - Properties
    
    private let apiClient: APIClient

    // MARK: - Init
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - UsersRepository
    
    func fetchUsers(page: Int, pageSize: Int) async throws -> UsersPage {
        guard let url = APIEndpoint.users(page: page, pageSize: pageSize).url else {
            throw APIError.badRequest
        }
        let response: UsersResponseDTO = try await apiClient.fetch(from: url)
        debugPrint("response: page: \(page), count:\(response.items.count), hasMore: \(response.hasMore)")
        return UsersPage(
            users: response.items.map { $0.toDomain() },
            hasMore: response.hasMore
        )
    }
}
