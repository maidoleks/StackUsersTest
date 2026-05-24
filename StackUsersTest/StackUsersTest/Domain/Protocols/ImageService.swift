//
//  ImageService.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 25/05/2026.
//

import Foundation

protocol ImageService {
    func load(from url: URL) async -> Data?
}
