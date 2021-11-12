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
     
        //let bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        //bar.button?.action = #selector(printShit)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        statusItem?.button?.title = "RSS Notifier"
        
        //if let button = statusItem?.button {
         // button.image = NSImage(named:NSImage.Name("rss-icon"))
            //button.action = #selector(printQuote(_:))
          //  button.title = "fuck"
        //}
        
        
        //statusItem?.button?.action = #selector(printShit)
        
        
       // let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        // let subMenu = NSMenu()
        
        
        
        // let refreshItem = NSMenuItem()
        // let categoryItem = NSMenuItem()
        
        
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
    
    @objc func printQuote(_ sender: Any?) {
      let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
      let quoteAuthor = "Mark Twain"
      
      print("\(quoteText) — \(quoteAuthor)")
    }
    
    
    @objc func printShit() {
        print("FUCK YOU WHORE")
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
        dateFormatter.dateFormat = "MM/dd, HH:mm"
        let timeSincePub = Date().timeIntervalSince(item.pubDate!)
        let timeSincePubInMin = Int(timeSincePub) / 60
        let time = calculateTime(minutesSincePub: timeSincePubInMin)
        
        let dateStr = dateFormatter.string(from: item.pubDate!)
        // let title = item.title! + "\t" + dateStr
        let title = item.title! + "\t" + String(time)
        return title
    }
    
    func calculateTime(minutesSincePub: Int) -> String {
        var time = String(minutesSincePub) + "m"
        if (minutesSincePub > 60) {
            let hours = minutesSincePub / 60
            let minutes = minutesSincePub % 60
            time = String(hours) + "h " + String(minutes) + "m"
        }
        
        return time
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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }


}

