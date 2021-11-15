//
//  ViewController.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa

class ViewController: NSViewController {
    
    var statusItem: NSStatusItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Här får jag inte vara. Det finns barn här")

        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "RSS Notifier"
        let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        let refreshItem = NSMenuItem()
        refreshItem.title = "Refresh"
        refreshItem.target = self
        statusBarMenu.addItem(refreshItem)
        statusItem?.menu = statusBarMenu

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

