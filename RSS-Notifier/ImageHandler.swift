//
//  ImageHandler.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2022-01-01.
//

import AppKit
import FaviconFinder

private let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
private let fh = FileHandler()


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


/// Saves the favicon as a image locally in the cache folder
///  - Parameters:
///     imageTitle - The name of the image file
///     icon - The image to be saved
///
///  - Returns: icon from the website
func saveImage(_ imageTitle: String, _ icon: NSImage) {
//    let cleanTitle = cleanName(imageTitle)
//    let url = directory.appendingPathComponent(cleanTitle+".png")

    let url = fh.createFileName(filename: imageTitle, fileFormat: "png", dir: directory)
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
//    let cleanTitle = cleanName(imageTitle)
//    let imageURL = directory.appendingPathComponent(cleanTitle+".png")
    return fh.createFileName(filename: imageTitle, fileFormat: "png", dir: directory)
}

func openImage(_ imageTitle: String) -> NSImage? {
    let fileURL = loadImageURL(imageTitle)
    do {
        let imageData = try Data(contentsOf: fileURL)
        return NSImage(data: imageData)!
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}

/// Parses the html and finds the favicon using FaviconFinder
///
///  - Parameters:
///     html - The link of the website
///
///  - Returns: icon from the website
func getFavicon(html: String) async throws -> NSImage {
    print(html)
    
    guard let iconUrl = URL(string: (html)) else {
        let image = NSImage(named: "AppIcon")!
        return image
    }
    do {
        print(iconUrl)
        let favicon = try await FaviconFinder(url: iconUrl).downloadFavicon()
//            print("URL of Favicon: \(favicon.url)")
        return favicon.image
    } catch {
        print("\(html)")
        throw FaviconError.failedToFindFavicon
    }
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
