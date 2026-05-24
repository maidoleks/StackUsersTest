//
//  DefaultsFollowService.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

final class DefaultsFollowService: FollowService {
    
    // MARK: - Properties
    
    private let defaults: UserDefaults
    private let key = "followedUserIds"

    private var followedIds: Set<Int> {
        get {
            let array = defaults.array(forKey: key) as? [Int] ?? []
            return Set(array)
        }
        set {
            defaults.set(Array(newValue), forKey: key)
        }
    }

    // MARK: - Init
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - FollowService
    
    func isFollowed(userId: Int) -> Bool {
        followedIds.contains(userId)
    }

    func follow(userId: Int) {
        var ids = followedIds
        ids.insert(userId)
        followedIds = ids
    }

    func unfollow(userId: Int) {
        var ids = followedIds
        ids.remove(userId)
        followedIds = ids
    }
}
