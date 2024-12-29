//
//  ArticleAPI.swift
//  BlogMobile
//
//  Created by yy on 2024/12/29.
//

import Foundation
import Moya

// Defines the API endpoints
enum ArticleAPI {
    case getArticles(page: Int, size: Int, locale: String)
}

extension ArticleAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.arcblock.io")!
    }

    var path: String {
        switch self {
        case .getArticles:
            return "/blog/api/blogs"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getArticles:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getArticles(let page, let size, let locale):
            return .requestParameters(
                parameters: ["page": page, "size": size, "locale": locale],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }

    var sampleData: Data {
        return Data()
    }
}
