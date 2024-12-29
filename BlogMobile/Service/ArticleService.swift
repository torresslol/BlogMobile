//
//  ArticleService.swift
//  BlogMobile
//
//  Created by yy on 2024/12/27.
//

import Foundation
import Moya

// MARK: - Service Layer
// Protocol for the service layer
protocol ArticleService {
    func getArticles(page: Int, size: Int, locale: String) async throws -> [Article]
}

// Implementation of the service protocol
class ArticleServiceImpl: ArticleService {
    private let repository: ArticleRepository = ArticleRepository()
    
    func getArticles(page: Int, size: Int, locale: String) async throws -> [Article] {
        return try await repository.getArticles(page: page, size: size, locale: locale)
    }
}

