//
//  APIEndpoint.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

enum APIEndpoint {
    case users(page: Int, pageSize: Int)
    
    var url: URL? {
        switch self {
        case let .users(page, pageSize):
            var components = URLComponents(string: "\(AppConstants.baseURL)/users")
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pagesize", value: "\(pageSize)"),
                URLQueryItem(name: "order", value: "desc"), // TODO: mb move it to constatns also
                URLQueryItem(name: "sort", value: "reputation"),
                URLQueryItem(name: "site", value: "stackoverflow")
            ]
            return components?.url
        }
    }
}
