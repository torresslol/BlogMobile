//
//  ArticleLayoutCache.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import UIKit

final class ArticleLayoutCacheManager {
    static let shared = ArticleLayoutCacheManager()
    
    private var cache: [String: ArticleLayoutCache] = [:]
    private let queue = DispatchQueue(label: "com.app.ArticleLayoutCache", attributes: .concurrent)
    
    private init() {}
    
    // MARK: - Layout Retrieval
    func getLayout(for article: Article, width: CGFloat) -> ArticleLayoutCache {
        let cacheKey = "\(article.id)_\(width)"
        
        // Retrieve from cache
        if let cachedLayout = queue.sync(execute: { cache[cacheKey] }) {
            return cachedLayout
        }
        
        // Calculate new layout
        let layout = ArticleLayoutCache.calculate(for: article, width: width)
        
        // Store in cache
        queue.async(flags: .barrier) {
            self.cache[cacheKey] = layout
        }
        
        return layout
    }
    
    // MARK: - Cache Management
    func clearCache() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}

// MARK: - ArticleLayoutCache Structure
class ArticleLayoutCache {
    let totalHeight: CGFloat
    let titleHeight: CGFloat
    let summaryHeight: CGFloat
    
    init(totalHeight: CGFloat, titleHeight: CGFloat, summaryHeight: CGFloat) {
        self.totalHeight = totalHeight
        self.titleHeight = titleHeight
        self.summaryHeight = summaryHeight
    }
    
    // MARK: - Layout Calculation
    static func calculate(for article: Article, width: CGFloat) -> ArticleLayoutCache {
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 12
        let imageWidth: CGFloat = 80
        let contentWidth = width - horizontalPadding * 2 - imageWidth - horizontalPadding
        
        // Calculate title height
        let titleFont = UIFont.title
        let titleHeight = article.title.boundingRectFast(
            withMaxWidth: contentWidth,
            font: titleFont,
            maxLine: 2
        ).height.ceil
        
        // Calculate summary height
        let summaryFont = UIFont.body
        let summaryHeight = article.excerpt.boundingRectFast(
            withMaxWidth: contentWidth,
            font: summaryFont,
            maxLine: 4
        ).height.ceil
        
        // Fixed heights
        let headerHeight: CGFloat = 15
        let statsHeight: CGFloat = 15
        let spacing: CGFloat = 8
        
        // Calculate total height
        let totalHeight = verticalPadding + headerHeight + spacing +
                         max(titleHeight + spacing + summaryHeight, imageWidth) +
                         spacing + verticalPadding + statsHeight + verticalPadding + spacing
        
        return ArticleLayoutCache(
            totalHeight: totalHeight,
            titleHeight: titleHeight,
            summaryHeight: summaryHeight
        )
    }
}
