//
//  MockFollowService.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 25/05/2026.
//


@testable import StackUsersTest

final class MockFollowService: FollowService {
    private(set) var followedIds: Set<Int> = []

    func isFollowed(userId: Int) -> Bool {
        followedIds.contains(userId)
    }

    func follow(userId: Int) {
        followedIds.insert(userId)
    }

    func unfollow(userId: Int) {
        followedIds.remove(userId)
    }
}
