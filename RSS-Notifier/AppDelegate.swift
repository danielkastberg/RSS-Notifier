//
//  AppDelegate.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var channels: Array<Channel> = []
    var channel: Channel = Channel()
    var items: Array<RSSItem> = []
    
    var statusItem: NSStatusItem?
    let rss = RSSReader()
    
    
    let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
    var subMenu = NSMenu()
    
    
    
    let refreshItem = NSMenuItem()
    let categoryItem = NSMenuItem()

    
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
     
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "RSS Notifier"
        
        
       // let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        // let subMenu = NSMenu()
        
        
        
        // let refreshItem = NSMenuItem()
        // let categoryItem = NSMenuItem()
        
        for element in items {
            print("kommer jag in")
            let article = NSMenuItem()
            article.title = element.title!
            print(article.title)
            subMenu.addItem(article)
            
        }
        
        
        refreshItem.title = "Refresh"
        refreshItem.action = #selector(rssRead)
        refreshItem.target = self
        
        categoryItem.title = "Category"
        categoryItem.target = self
        
        categoryItem.submenu = subMenu
        
        
        statusBarMenu.addItem(refreshItem)
        statusBarMenu.addItem(categoryItem)
        
        statusItem?.menu = statusBarMenu



    }
    
    @objc func refreshRss() {
        rss.startRss{ (output) -> Void in
            self.items
            print(self.items.count)
            print(self.items)
        }

        for item in items {
            print(item.title)
        }
    
    }
    
    @objc func rssRead() {
        self.subMenu = NSMenu()
        var i = 0
        let url: URL = URL(string: "https://m.sweclockers.com/feeds/forum/trad/999559")!

        AF.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.value {
                /// Do something with your new RSSFeed object!
                for item in feed.items {
                    let article = NSMenuItem()
                    let title = self.formatDate(item: item)
                    
                    //let article = NSMenuItem(title: title, action: #selector(self.openBrowser(urlSender:)), keyEquivalent: String(i))
                    let someObj: NSString = item.link! as NSString
                    article.representedObject = someObj
                    article.action = #selector(self.openBrowser(urlSender:))
                    article.title = title
                    i+=1

                    print(article.title)
                    self.subMenu.addItem(article)
                }
            }
        }
        categoryItem.submenu = subMenu
    }
    
    
    @objc func openBrowser(urlSender: NSMenuItem) {
        let urlString = urlSender.representedObject
        let url = URL(string: urlString as! String)!
        NSWorkspace.shared.open(url)
    }
    
    func formatDate(item: RSSItem) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd, hh:mm"
        let dateStr = dateFormatter.string(from: item.pubDate!)
        let title = item.title! + "\t" + dateStr
        return title
    }
 
    
    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Spara alla kanaler som jag vill hämta från i ett XML dok.
        //Spara URL i XML dok.
        //Loopa igenom XML tills tomt, hittar jag en URL gör en sökning med RSS
        rssRead()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

