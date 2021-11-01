//
//  AppDelegate.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var channels: Array<Channel> = []
    var channel: Channel = Channel()
    var items: Array<Item> = []
    
    var statusItem: NSStatusItem?
    let rss = RSSReader()
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
     
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "RSS Notifier"
        
        
        let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        let subMenu = NSMenu()
        
        
        
        let refreshItem = NSMenuItem()
        let categoryItem = NSMenuItem()
        
        for element in items {
            print("kommer jag in")
            let article = NSMenuItem()
            article.title = element.title
            print(article.title)
            subMenu.addItem(article)
            
        }
        
        
        refreshItem.title = "Refresh"
        refreshItem.action = #selector(refreshRss)
        refreshItem.target = self
        
        categoryItem.title = "Category"
        categoryItem.target = self
        
        categoryItem.submenu = subMenu
        
        
        statusBarMenu.addItem(refreshItem)
        statusBarMenu.addItem(categoryItem)
        
        statusItem?.menu = statusBarMenu



    }
    
    @objc func refreshRss() {
        rss.startRss()
    
    }

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Spara alla kanaler som jag vill hämta från i ett XML dok.
        //Spara URL i XML dok.
        //Loopa igenom XML tills tomt, hittar jag en URL gör en sökning med RSS läsaren
        refreshRss()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

