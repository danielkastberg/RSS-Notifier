//
//  HTMLFaviconFinder.swift
//  Pods
//
//  Created by William Lumley on 26/5/21.
//

import Foundation

#if canImport(SwiftSoup)
import SwiftSoup

#endif

class WebApplicationManifestFaviconFinder: FaviconFinderProtocol {

    // MARK: - Types

    struct WebApplicationManifestFileReference {
        let rel: String
        let href: String
    }

    // MARK: - Properties

    var url: URL
    var preferredType: String
    var logEnabled: Bool

    /// The preferred type of favicon we're after
    //var preferredType: String? = FaviconType.appleTouchIcon.rawValue

    required init(url: URL, preferredType: String?, logEnabled: Bool) {
        self.url = url
        self.preferredType = preferredType ?? FaviconType.launcherIcon4x.rawValue //Default to `launcherIcon4x` type if user does not present us with one
        self.logEnabled = logEnabled
    }

    func search() async throws -> FaviconURL {

        let strongSelf = self

        let data = try await URLSession.shared.data(from: `self`.url).0
        
        guard let html = String(data: data, encoding: .utf8) else {
            if self.logEnabled {
                print("Could NOT get favicon from url: \(self.url), could not parse HTML.")
            }
            throw FaviconError.failedToParseHTML
        }
        guard let manifestURL = strongSelf.manifestUrl(from: html) else {
            if self.logEnabled {
                print("Could NOT get manifest file from url: \(self.url), failed to parse favicon from WebApplicationManifestFile.")
            }
            throw FaviconError.failedToFindWebApplicationManifestFile
        }
        
        let manifestData = try await self.downloadManifestFile(from: manifestURL)
        
        guard let faviconURL = strongSelf.faviconURL(from: manifestData) else {
            if self.logEnabled {
                print("Could NOT get favicon from url: \(self.url), failed to parse favicon from manifest data.")
            }
            throw FaviconError.failedToDownloadFavicon
        }
        
        return faviconURL
    }

}

private extension WebApplicationManifestFaviconFinder {

    /**
     Parses the provided HTML for the manifest file URL
     - parameter htmlStr: The HTML that we will be parsing and iterating through to find the favicon
     - returns: The URL that the manifest file can be found at
    */
    func manifestUrl(from htmlStr: String) -> URL? {
        var htmlOpt: Document?
        do {
            htmlOpt = try SwiftSoup.parse(htmlStr)
        }
        catch let error {
            if logEnabled {
                print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            }
            return nil
        }
        
        guard let html = htmlOpt else {
            if logEnabled {
                print("Could NOT parse HTML from string: \(htmlStr)")
            }
            return nil
        }
        
        guard let head = html.head() else {
            if logEnabled {
                print("Could NOT parse HTML head from string: \(htmlStr)")
            }
            return nil
        }

        // Where we're going to store our HTML favicons
        var fileReference: WebApplicationManifestFileReference?

        var allLinks = Elements()
        do {
            allLinks = try head.select("link")
        }
        catch let error {
            if logEnabled {
                print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
            }
            return nil
        }

        //Extract the 'manifest' href tag
        for element in allLinks {
            do {
                let rel = try element.attr("rel")
                let href = try element.attr("href")

                //If this is our manifest href tag
                if rel == "manifest" {
                    fileReference = WebApplicationManifestFileReference(rel: rel, href: href)
                }
            }
            catch let error {
                if logEnabled {
                    print("Could NOT parse HTML due to error: \(error). HTML: \(htmlStr)")
                }
                continue
            }
        }

        guard let fileReference = fileReference else {
            if logEnabled {
                print("Could NOT find any HTML href tag that points to a manifest file")
            }
            return nil
        }

        let href = fileReference.href

        var hrefUrl: URL?

        // If we don't have a http or https prepended to our href, prepend our base domain
        if Regex.testForHttpsOrHttp(input: href) == false {
            let baseRef = {() -> URL in
                // Try and get the base URL from a HTML tag if we can
                if let baseRef = try? html.head()?.getElementsByTag("base").attr("href"), let baseRefUrl = URL(string: baseRef, relativeTo: self.url) {
                    return baseRefUrl
                }
                
                // We couldn't get the base URL from a HTML tag, so we'll use the base URL that we have on hand
                else {
                    return self.url
                }
            }

            hrefUrl = URL(string: href, relativeTo: baseRef())
        }
        
        // Our href is a proper URL, nevermind
        else {
            hrefUrl = URL(string: href)
        }
        
        return hrefUrl
    }

    /**
     Fetches and parses the manifest file from the URL provided
     - parameter manifestURL: The URL that the manifest file is supposedly located at
     - parameter onSuccess: The closure that will be called once we find a valid manifest file
     - parameter onError: The closure that will be called if we fail to find a valid manifest file
    */
    func downloadManifestFile(from manifestURL: URL) async throws -> Dictionary<String, Any> {
        let request = URLRequest(url: manifestURL)

        let data = try await URLSession.shared.data(for: request).0
        
        guard let manifestData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw FaviconError.failedToParseWebApplicationManifestFile
        }
        
        return manifestData
    }

    /**
     Parses the provided manifest data for the favicon URL
     - parameter htmlStr: The manifest data that we will be parsing and iterating through to find the favicon
     - returns: The URL that the favicon can be found at
    */
    func faviconURL(from manifestData: Dictionary<String, Any>) -> FaviconURL? {
        guard let icons = manifestData["icons"] as? Array<Dictionary<String, String>> else {
            return nil
        }

        // Get the most preferred icon
        guard let mostPreferrableIcon = self.mostPreferrableIcon(iconInfos: icons) else {
            return nil
        }

        // Build our URL from the icon
        guard let iconUrl = URL(string: mostPreferrableIcon.iconKey, relativeTo: self.url) else {
            return nil
        }

        return FaviconURL(url: iconUrl, type: mostPreferrableIcon.type)
    }

    /**
     Returns the most desirable FaviconRelType from an array of FaviconRelType
     - parameter icons: Our array of our image links that we have to choose a desirable one from
     - returns: The most preferred image link from our aray of icons
     */
    func mostPreferrableIcon(iconInfos: Array<Dictionary<String, String>>) -> (iconKey: String, type: FaviconType)? {
        
        // Check for the users preferred type
        if let iconInfo = iconInfos.first(where: { iconInfo in
            guard let icon = iconInfo["src"] else { return false }
            return FaviconType(rawValue: icon)?.rawValue == preferredType
        }) {
            guard let src = iconInfo["src"] else { return nil }
            return (iconKey: src, type: FaviconType(rawValue: src)!)
        }

        // Check for launcherIcon4x type
        else if let iconInfo = iconInfos.first(where: { iconInfo in
            guard let icon = iconInfo["src"] else { return false }
            return FaviconType(rawValue: icon) == .launcherIcon4x
        }) {
            guard let src = iconInfo["src"] else { return nil }
            return (iconKey: src, type: FaviconType(rawValue: src)!)
        }

        // Check for launcherIcon3x type
        else if let iconInfo = iconInfos.first(where: { iconInfo in
            guard let icon = iconInfo["src"] else { return false }
            return FaviconType(rawValue: icon) == .launcherIcon3x
        }) {
            guard let src = iconInfo["src"] else { return nil }
            return (iconKey: src, type: FaviconType(rawValue: src)!)
        }

        // Check for launcherIcon2x type
        else if let iconInfo = iconInfos.first(where: { iconInfo in
            guard let icon = iconInfo["src"] else { return false }
            return FaviconType(rawValue: icon) == .launcherIcon2x
        }) {
            guard let src = iconInfo["src"] else { return nil }
            return (iconKey: src, type: FaviconType(rawValue: src)!)
        }

        // Check for launcherIcon1x type
        else if let iconInfo = iconInfos.first(where: { iconInfo in
            guard let icon = iconInfo["src"] else { return false }
            return FaviconType(rawValue: icon) == .launcherIcon1x
        }) {
            guard let src = iconInfo["src"] else { return nil }
            return (iconKey: src, type: FaviconType(rawValue: src)!)
        }

        return nil
    }

}
