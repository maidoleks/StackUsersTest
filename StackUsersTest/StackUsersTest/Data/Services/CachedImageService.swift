//
//  CachedImageService.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 25/05/2026.
//

import Foundation

final class CachedImageService: ImageService {
    // MARK: - Properties
    
    private let cache = NSCache<NSURL, NSData>()
    
    // MARK: - ImageService
    
    func load(from url: URL) async -> Data? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        cache.setObject(data as NSData, forKey: url as NSURL)
        return data
    }
}
