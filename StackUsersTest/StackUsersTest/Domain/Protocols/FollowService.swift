//
//  FollowService.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

protocol FollowService {
    func isFollowed(userId: Int) -> Bool
    func follow(userId: Int)
    func unfollow(userId: Int)
}
