//
//  APIClient.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

protocol APIClient {
    func fetch<T: Decodable>(from url: URL) async throws -> T
}
