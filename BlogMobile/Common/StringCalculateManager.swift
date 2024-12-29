//
//  StringCalculateManager.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import Foundation
import UIKit

class StringCalculateManager {
    static let shared = StringCalculateManager()
    var fontDictionary = [String: [String: CGFloat]]()
    var numsNeedToSave = 0
    var fileUrl: URL = {
        let manager = FileManager.default
        var filePath = manager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        filePath!.appendPathComponent("font_dictionary.json")
        print("font_dictionary.json path is ===\(filePath!)")
        return filePath!
    }()

    init() {
        readFontDictionaryFromDisk()
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(saveFontDictionaryToDisk),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(saveFontDictionaryToDisk),
                name: UIApplication.willTerminateNotification,
                object: nil
            )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Font Management

    func createNewFont(font: UIFont) -> [String: CGFloat] {
        let array: [String] = [
            "中", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "“", ";", "？", ",", "［", "]", "、", "【", "】", "?", "!", ":", "|"
        ]
        var widthDictionary = [String: CGFloat]()
        var singleWordRect = CGRect.zero
        for string in array {
            singleWordRect = string
                .boundingRect(with: CGSize(width: 100, height: 100),
                              options: .usesLineFragmentOrigin,
                              attributes: [NSAttributedString.Key.font: font],
                              context: nil)
            widthDictionary[string] = singleWordRect.size.width
        }
        widthDictionary["singleLineHeight"] = singleWordRect.size.height
        let fontKey = "\(font.fontName)-\(font.pointSize)"
        fontDictionary[fontKey] = widthDictionary
        numsNeedToSave = array.count
        saveFontDictionaryToDisk()
        return widthDictionary
    }

    // MARK: - Size Calculation

    func calculateSize(withString string: String, maxWidth: CGFloat, font: UIFont, maxLine: Int) -> CGRect {
        let totalWidth: CGFloat = calculateTotalWidth(
            string: string,
            font: font
        )
        var widthDictionary = fetchWidthDictionaryWith(font)
        let singleLineHeight = widthDictionary["singleLineHeight"]!
        let numsOfLine = ceil(totalWidth/maxWidth)
        let maxLineCGFloat = CGFloat(maxLine)
        let resultwidth = numsOfLine <= 1 ? totalWidth : maxWidth
        let resultLine = numsOfLine < maxLineCGFloat ? numsOfLine : maxLineCGFloat
        return CGRect.init(
            x: 0,
            y: 0,
            width: resultwidth,
            height: resultLine * singleLineHeight
        )
    }

    func calculateSize(withString string: String, maxWidth: CGFloat, font: UIFont) -> CGRect {
        let totalWidth: CGFloat = calculateTotalWidth(
            string: string,
            font: font
        )
        var widthDictionary = fetchWidthDictionaryWith(font)
        let singleLineHeight = widthDictionary["singleLineHeight"]!
        let numsOfLine = ceil(totalWidth/maxWidth)
        let resultwidth = numsOfLine <= 1 ? totalWidth : maxWidth
        return CGRect.init(
            x: 0,
            y: 0,
            width: resultwidth,
            height: numsOfLine * singleLineHeight
        )
    }

    func calculateSize(withString string: String, maxSize: CGSize, font: UIFont) -> CGRect {
        let totalWidth: CGFloat = calculateTotalWidth(
            string: string,
            font: font
        )
        var widthDictionary = fetchWidthDictionaryWith(font)
        let singleLineHeight = widthDictionary["singleLineHeight"]!
        let numsOfLine = ceil(totalWidth/maxSize.width)
        let maxLineCGFloat = floor(maxSize.height/singleLineHeight)
        let resultwidth = numsOfLine <= 1 ? totalWidth : maxSize.width
        let resultLine = numsOfLine < maxLineCGFloat ? numsOfLine : maxLineCGFloat
        return CGRect.init(
            x: 0,
            y: 0,
            width: resultwidth,
            height: resultLine * singleLineHeight
        )
    }

    // MARK: - Total Width Calculation

    func calculateTotalWidth(string: String, font: UIFont) -> CGFloat {
        var totalWidth: CGFloat = 0
        let fontKey = "\(font.fontName)-\(font.pointSize)"
        var widthDictionary = fetchWidthDictionaryWith(font)
        let chineseWidth = widthDictionary["中"]!
        for character in string {
            if "\u{4E00}" <= character  && character <= "\u{9FA5}" {
                totalWidth += chineseWidth
            } else if let width = widthDictionary[String(character)] {
                totalWidth += width
            } else {
                let tempString = String(character)
                let width = tempString.boundingRect(
                    with: CGSize(
                        width: CGFloat.greatestFiniteMagnitude,
                        height: CGFloat.greatestFiniteMagnitude
                    ),
                    options: .usesLineFragmentOrigin,
                    attributes: [NSAttributedString.Key.font: font],
                    context: nil
                ).size.width
                totalWidth += width
                widthDictionary[tempString] = width
                numsNeedToSave += 1
            }
        }
        fontDictionary[fontKey] = widthDictionary
        if numsNeedToSave > 10 {
            saveFontDictionaryToDisk()
        }
        return totalWidth
    }

    // MARK: - Font Dictionary Management

    func fetchWidthDictionaryWith(_ font: UIFont) -> [String: CGFloat] {
        var widthDictionary = [String: CGFloat]()
        let fontKey = "\(font.fontName)-\(font.pointSize)"
        if let dictionary = StringCalculateManager.shared.fontDictionary[fontKey] {
            widthDictionary = dictionary
        } else {
            widthDictionary = StringCalculateManager.shared.createNewFont(font: font)
        }
        return widthDictionary
    }

    let queue = DispatchQueue(label: "com.StringCalculateManager.queue")

    // MARK: - Disk Management

    @objc func saveFontDictionaryToDisk() {
        guard numsNeedToSave > 0 else {
            return
        }
        numsNeedToSave = 0
        queue.async {
            do {
                var data: Data?
                if #available(iOS 11.0, *) {
                    data = try? JSONSerialization.data(
                        withJSONObject: self.fontDictionary,
                        options: .sortedKeys
                    )
                } else {
                    data = try? JSONSerialization.data(
                        withJSONObject: self.fontDictionary,
                        options: .prettyPrinted
                    )
                }
                try data?.write(to: self.fileUrl)
                print("font_dictionary saved to disk, font_dictionary=\(self.fontDictionary)")
            } catch {
                print("font_dictionary storage failed error=\(error)")
            }
        }
    }

    func readFontDictionaryFromDisk() {
        do {
            let data = try Data(contentsOf: fileUrl)
            let json = try JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
            )
            guard let dict = json as? [String: [String: CGFloat]] else {
                return
            }
            fontDictionary = dict
            print(fontDictionary)
            print("font_dictionary read successfully, font_dictionary=\(fontDictionary)")
        } catch {
            print("font_dictionary does not exist or read failed on first run")
        }
    }
}

extension String {
    // MARK: - String Size Calculation

    func boundingRectFast(withMaxWidth width: CGFloat, font: UIFont, maxLine: Int) -> CGRect {
        let rect = StringCalculateManager.shared.calculateSize(
            withString: self,
            maxWidth: width,
            font: font,
            maxLine: maxLine
        )
        return rect
    }

    func boundingRectFast(withMaxWidth width: CGFloat, font: UIFont) -> CGRect {
        let rect = StringCalculateManager.shared.calculateSize(
            withString: self,
            maxWidth: width,
            font: font
        )
        return rect
    }

    func boundingRectFast(withMaxSize size: CGSize, font: UIFont) -> CGRect {
        let rect = StringCalculateManager.shared.calculateSize(
            withString: self,
            maxSize: size,
            font: font
        )
        return rect
    }
}