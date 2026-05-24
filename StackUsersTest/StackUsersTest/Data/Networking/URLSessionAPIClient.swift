//
//  URLSessionAPIClient.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import Foundation

final class URLSessionAPIClient: APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("APIError.badResponse")
            throw APIError.badResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            debugPrint("APIError.errorResponse(statusCode: \(httpResponse.statusCode))")
            throw APIError.errorResponse(statusCode: httpResponse.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
