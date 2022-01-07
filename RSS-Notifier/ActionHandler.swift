//
//  ActionHandler.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2022-01-07.
//

import Foundation
import AppKit

class ActionHandler {
    private var link: String = ""
    static let sharedActionHandler = ActionHandler()
    
    private init() { }
    
    /// Opens the browser from the link
    ///  - Parameters:
    ///     link - The link of the website
    func open(link: String) {
        let urlString = link
        guard let url = URL(string: urlString) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
