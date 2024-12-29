//
//  AppInit.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import Foundation
import Kingfisher

final class AppInit {
    
    // MARK: - Setup Methods
    
    static func setupStringCalculate() {
        Task { 
            _ = StringCalculateManager.shared
        }
    }
    
    static func setupKingfisher() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        
        ImageCache.default.diskStorage.config.sizeLimit = 80 * 1024 * 1024
        
        ImageCache.default.diskStorage.config.expiration = .days(7)
        
        KingfisherManager.shared.downloader.downloadTimeout = 15.0 // 15 seconds timeout
    }
    
    static func setupWebView() {
        _ = WebViewManager.shared
    }
    
}
