//
//  String+Trimming.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import Foundation

public extension String {
    // MARK: - String Cleaning

    var cleaned: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
