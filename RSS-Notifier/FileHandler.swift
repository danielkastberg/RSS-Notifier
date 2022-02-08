//
//  FileHandler.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2022-02-07.
//

import Foundation

class FileHandler {
    func cleanName(_ fileName: String) -> String {
        let buff = fileName
        let pattern = "\\W"
        let replacement = ""
        let cleanTitle = buff.replacingOccurrences(
            of: pattern,
            with: replacement,
            options: .regularExpression
        )
        let shorterName = cleanTitle.maxLength(length: 10)
        return shorterName
    }

    func createFileName(filename: String, fileFormat: String, dir: URL) -> URL {
        let cleanTitle = cleanName(filename)
        let url = dir.appendingPathComponent(cleanTitle + "." + fileFormat)
        return url
    }

    func fileExistsShort(filename: String, fileFormat: String, dir: URL) -> Bool {
        let file = createFileName(filename: filename, fileFormat: fileFormat, dir: dir)
        return FileManager.default.fileExists(atPath: file.path)
    }
    
    func fileExists(filename: String, fileFormat: String, dir: URL) -> Bool {
        let file = dir.appendingPathComponent(filename + "." + fileFormat)
        return FileManager.default.fileExists(atPath: file.path)
    }
}

