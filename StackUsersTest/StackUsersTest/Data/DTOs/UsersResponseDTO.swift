//
//  UsersResponseDTO.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

struct UsersResponseDTO: Codable {
    let items: [UserDTO]
    let hasMore: Bool
}

// MARK: - Codable

extension UsersResponseDTO {
    enum CodingKeys: String, CodingKey {
        case items
        case hasMore = "has_more"
    }
}
