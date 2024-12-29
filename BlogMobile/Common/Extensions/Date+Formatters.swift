//
//  DateFormatters.swift
//  BlogMobile
//
//  Created by yy on 2024/12/29.
//

import Foundation

enum DateFormatters {
    // MARK: - Date Formatters

    static let parser: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let displayStyle: Date.FormatStyle = Date.FormatStyle()
        .year()
        .month(.twoDigits)
        .day(.twoDigits)
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
}

extension String {
    // MARK: - Date Formatting

    func toFormattedDate() -> String {
        guard let date = DateFormatters.parser.date(from: self) else {
            print("Failed to parse ISO date: \(self)")
            return self
        }
        return date.formatted(DateFormatters.displayStyle)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ", ", with: " ")
    }
}
