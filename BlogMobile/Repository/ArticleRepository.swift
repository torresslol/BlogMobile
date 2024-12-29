//
//  ArticleRepository.swift
//  BlogMobile
//
//  Created by yy on 2024/12/29.
//

import Foundation
import Moya

// MARK: - MoyaProvider Extension for Async/Await Support
extension MoyaProvider {
    func request(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Repository Layer
// Handles specific network requests
class ArticleRepository {
    private let provider = MoyaProvider<ArticleAPI>()
    
    func getArticles(page: Int, size: Int, locale: String) async throws -> [Article] {
        // Perform network request
        let response = try await provider.request(.getArticles(page: page, size: size, locale: locale))
        
        // Check for successful status codes
        guard (200...299).contains(response.statusCode) else {
            throw MoyaError.statusCode(response)
        }
        
        // Decode the response data to Article array
        let articles = try JSONDecoder().decode(ArticleListResponse.self, from: response.data).articles
        return articles
    }
}
