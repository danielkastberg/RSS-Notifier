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
    
    
    let statusBarMenu = NSMenu()
    var subMenu = NSMenu()
    
    
    
    let refreshItem = NSMenuItem()
    let categoryItem = NSMenuItem()
    

    
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
     
        //let bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        //bar.button?.action = #selector(printShit)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        

        
        // Checks if there is an image to use as icon.
        // If not loads a title instead
        if let image = NSImage(named: "AppIcon") {
            image.isTemplate = true
            image.size = CGSize(width: 19, height: 19)
            statusItem?.button?.image = image
        }
        else {
            statusItem?.button?.title = "RSS Notifier"
        }
        
 
        
  
        
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
        
        
        
        // Creates a item to Quit the program
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        

        // Creates a NSMenuItem to handle the RSS refresh
        refreshItem.title = "Refresh"
        refreshItem.action = #selector(rssRead)
        refreshItem.target = self
        
        categoryItem.title = "Category"
        categoryItem.target = self
        
        categoryItem.submenu = subMenu
        
        
        // Adds all the items to the menu that pops down when clicking the icon
        statusBarMenu.addItem(quitItem)
        statusBarMenu.addItem(refreshItem)
        statusBarMenu.addItem(categoryItem)

        
        statusItem?.menu = statusBarMenu


    }
    
    @objc func printQuote(_ sender: Any?) {
      let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
      let quoteAuthor = "Mark Twain"
      
      print("\(quoteText) — \(quoteAuthor)")
    }
    
    
    @objc func quit () {
        print("Quit to be implemented")
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

