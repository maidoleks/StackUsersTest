//
//  UserDTO.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

struct UserDTO: Codable {
    let userId: Int
    let displayName: String
    let reputation: Int
    let profileImage: String?
}

// MARK: - Codable

extension UserDTO {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case reputation
        case profileImage = "profile_image"
    }
}
