//
//  Article.swift
//  BlogMobile
//
//  Created by yy on 2024/12/27.
//

import Foundation
import IGListDiffKit

// MARK: - Article Model
class Article: Decodable, ListDiffable {
    let id: String
    let title: String
    let cover: String
    let excerpt: String
    let author: String
    let commentCount: Int
    let publishTime: String
    let slug: String
    let views: Int?
    
    // CodingKeys to map JSON keys
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case cover
        case excerpt
        case author
        case commentCount
        case publishTime
        case slug
        case views
        case labels
    }
    
    // Custom decoder implementation
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode basic fields and clean them
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title).cleaned
        cover = try container.decode(String.self, forKey: .cover).cleaned
        excerpt = try container.decode(String.self, forKey: .excerpt).cleaned
        author = try container.decode(String.self, forKey: .author).cleaned
        publishTime = try container.decode(String.self, forKey: .publishTime)
        slug = try container.decode(String.self, forKey: .slug)
        
        // Decode numeric types
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        views = try container.decodeIfPresent(Int.self, forKey: .views)
    }
    
    // MARK: - ListDiffable
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? Article else { return false }
        return id == other.id &&
               title == other.title &&
               cover == other.cover &&
               excerpt == other.excerpt &&
               author == other.author &&
               commentCount == other.commentCount &&
               publishTime == other.publishTime &&
               views == other.views
    }
}

extension Article {
    // Generate detail URL for the article
    func detailUrl() -> String {
        return "https://www.arcblock.io/blog/en/" + slug
    }
}

// MARK: - ArticleListResponse
struct ArticleListResponse: Decodable {
    let articles: [Article]
    
    private enum CodingKeys: String, CodingKey {
        case articles = "data"
    }
}
