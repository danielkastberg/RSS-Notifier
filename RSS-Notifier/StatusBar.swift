//
//  StatusBar.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Foundation

import Cocoa

class StatusBar : NSObject {
    func buildMenu() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "StatusBarApp"

        let menu = NSMenu()

        let aboutMenuItem = NSMenuItem()
        aboutMenuItem.title = "About"
        aboutMenuItem.target = self
        aboutMenuItem.action = #selector(about)
        menu.addItem(aboutMenuItem)

        statusItem.menu = menu
    }

    @objc func about() {
        print("XXX")
    }
 }



