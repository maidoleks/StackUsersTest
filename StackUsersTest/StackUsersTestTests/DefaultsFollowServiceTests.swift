//
//  DefaultsFollowServiceTests.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 25/05/2026.
//

import Foundation
import XCTest
@testable import StackUsersTest

final class DefaultsFollowServiceTests: XCTestCase {

    private func makeSut() -> DefaultsFollowService {
        DefaultsFollowService(defaults: UserDefaults(suiteName: UUID().uuidString)!)
    }

    func testNotFollowedByDefault() {
        XCTAssertFalse(makeSut().isFollowed(userId: 1))
    }

    func testFollowMakesUserFollowed() {
        let service = makeSut()
        service.follow(userId: 1)
        XCTAssertTrue(service.isFollowed(userId: 1))
    }

    func testUnfollowRemovesFollow() {
        let service = makeSut()
        service.follow(userId: 1)
        service.unfollow(userId: 1)
        XCTAssertFalse(service.isFollowed(userId: 1))
    }

    func testFollowingOneUserDoesNotAffectAnother() {
        let service = makeSut()
        service.follow(userId: 1)
        XCTAssertFalse(service.isFollowed(userId: 2))
    }

    func testMultipleUsersCanBeFollowedIndependently() {
        let service = makeSut()
        service.follow(userId: 1)
        service.follow(userId: 2)
        XCTAssertTrue(service.isFollowed(userId: 1))
        XCTAssertTrue(service.isFollowed(userId: 2))
    }

    func testUnfollowingNonFollowedUserIsNoop() {
        let service = makeSut()
        service.unfollow(userId: 99)
        XCTAssertFalse(service.isFollowed(userId: 99))
    }

    func testPersistsAcrossSeparateInstances() {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        let service1 = DefaultsFollowService(defaults: defaults)
        service1.follow(userId: 42)

        let service2 = DefaultsFollowService(defaults: defaults)
        XCTAssertTrue(service2.isFollowed(userId: 42))
    }

    func testUnfollowPersistsAcrossSeparateInstances() {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        let service1 = DefaultsFollowService(defaults: defaults)
        service1.follow(userId: 5)
        service1.unfollow(userId: 5)

        let service2 = DefaultsFollowService(defaults: defaults)
        XCTAssertFalse(service2.isFollowed(userId: 5))
    }
}
