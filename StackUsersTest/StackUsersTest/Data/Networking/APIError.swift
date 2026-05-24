//
//  APIError.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

enum APIError: Error {
    case badRequest
    case badResponse
    case errorResponse(statusCode: Int)
}
