//
//  ImageHandler.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2022-01-01.
//

import AppKit

private let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]


private func cleanName(_ fileName: String) -> String {
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

func imageExist(_ fileName: String) -> Bool {
    let cleanTitle = cleanName(fileName)
    let url = directory.appendingPathComponent(cleanTitle+".png")
    return FileManager.default.fileExists(atPath: url.path)
}



func saveImage(_ imageTitle: String, _ icon: NSImage) {
    let cleanTitle = cleanName(imageTitle)
    let url = directory.appendingPathComponent(cleanTitle+".png")

    // Convert to Data
    if let data = icon.tiffRepresentation {
        do {
            try data.write(to: url)
        } catch {
            print("Unable to Write Image Data to Disk")
        }
    }
}


func loadImageURL(_ imageTitle: String) -> URL {
    let cleanTitle = cleanName(imageTitle)
    let imageURL = directory.appendingPathComponent(cleanTitle+".png")
    
    return imageURL
}

func loadImage(_ imageTitle: String) -> NSImage? {
    let fileURL = loadImageURL(imageTitle)
    do {
        let imageData = try Data(contentsOf: fileURL)
        return NSImage(data: imageData)!
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}


extension String {
   func maxLength(length: Int) -> String {
       var str = self
       let nsString = str as NSString
       if nsString.length >= length {
           str = nsString.substring(with:
               NSRange(
                location: 0,
                length: nsString.length > length ? length : nsString.length)
           )
       }
       return str
   }
}
