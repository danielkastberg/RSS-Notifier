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

    /// Quits the program
    @objc func quit () {
        exit(0)
    }

     /// Opens the browser for the link that is sent.
     /// Links the menu item with the action.
     ///  - Parameters:
     ///     urlSender - A NSMenuItem containing a link-

     @objc func openBrowser(urlSender: NSMenuItem) {
         let urlString = urlSender.representedObject
         guard let url = URL(string: urlString as! String) else {
             return
         }
         NSWorkspace.shared.open(url)
     }
}
