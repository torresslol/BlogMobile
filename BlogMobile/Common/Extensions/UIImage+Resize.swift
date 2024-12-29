//
//  UIImage+Resize.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import UIKit
import Kingfisher

extension UIImageView {
    enum ImageResizeMode {
        case local  // Local resizing
        case oss    // OSS online resizing
    }
    
    // MARK: - Image Setting
    
    func setUrl(
        _ urlPath: String?,
        size: CGSize,
        mode: ImageResizeMode = .oss  // Default to OSS resizing
    ) {
        guard let urlPath = urlPath else { return }
        guard var components = URLComponents(string: urlPath) else { return }
        
        let scale = UIScreen.main.scale
        let targetWidth = Int(size.width * scale)
        let targetHeight = Int(size.height * scale)
        
        switch mode {
        case .oss:
            let ossQuery = "x-oss-process=image/resize,w_\(targetWidth),h_\(targetHeight),m_fill"
            if components.query == nil {
                components.query = ossQuery
            } else {
                components.query = components.query! + "&" + ossQuery
            }
            
            guard let finalUrl = components.url else { return }
            
            kf.setImage(
                with: finalUrl,
                options: [
                    .scaleFactor(scale)
                ]
            )
            
        case .local:
            guard let originalUrl = components.url else { return }
            
            kf.setImage(
                with: originalUrl,
                options: [
                    .processor(
                        DownsamplingImageProcessor(
                            size: size
                        )
                    ),
                    .scaleFactor(scale),
                    .processingQueue(.dispatch(.global()))
                ]
            )
        }
    }
}
