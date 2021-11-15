//
//  AppDelegate.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire

// Prova OPML bibliotek och se om det blir snabbare eller mer tillförlitigligt.

/*
 TODO
 Add OPML writing.
 Fix bug that not all sources url gets loaded
 Add notification support
 Add different shade in menu item to indicate that it has been read
 Maybe add read notification to be saved between instances
 Add icon for each source to be loaded for each article in the menu
 Add some window for a quick read of the rss description
 */


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var items: Array<RSSItem> = []
    
    var statusItem: NSStatusItem?

    
    let statusBarMenu = NSMenu()
    var subMenu = NSMenu()
    
    
    let refreshItem = NSMenuItem()
    let categoryItem = NSMenuItem()
    
    var listOfCategories = [NSMenuItem]()
    
    var urls = [""]
    

    
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let oplmR = OPMLReader()
        let category = oplmR.readOPML()
        
        let categories = category.getCategories()
        
        
        
        
        
        
        
        
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
        
        
 
        
        
        // Creates a item to Quit the program
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        

        // Creates a NSMenuItem to handle the RSS refresh
        refreshItem.title = "Refresh"
        refreshItem.action = #selector(rssRead)
        refreshItem.target = self
        
        
        
        for c in categories {
            var categoryItem = NSMenuItem()
            categoryItem.title = c.title
            for outline in c.items {
                urls.append(outline.xmlUrl)
                categoryItem = update(urlString: outline.xmlUrl, CategoryItem: categoryItem)
                print(categoryItem.title)
            }
            categoryItem.target = self
            statusBarMenu.addItem(categoryItem)
        }
        
        
        
//        categoryItem.title = "Category"
//        categoryItem.target = self
        
        categoryItem.submenu = subMenu
        
        
        // Adds all the items to the menu that pops down when clicking the icon
        statusBarMenu.addItem(quitItem)
        statusBarMenu.addItem(refreshItem)
//        statusBarMenu.addItem(categoryItem)

        
        statusItem?.menu = statusBarMenu
        
        // Removes the app from the dock
        NSApp.setActivationPolicy(.accessory)


    }
    
    
    
    
    @objc func quit () {
        exit(0)
    }
            
    @objc func rssRead() {
//        let urlString = urls.representedObject
//        let url = URL(string: urlString as! String)!
        self.subMenu = NSMenu()
        

        
        
        var i = 0
        //        let url: URL = URL(string: "https://m.sweclockers.com/feeds/forum/trad/999559")!
        
       for urlString in urls {
//           let url = URL(string: urlString)
//            let url = URL(string: urlString as! String)!
           
//           guard let url = URL(string: urlString) else {
//               print("CANNOT OPEN URL")
//               return
//           }
//
//           print(url)
//            AF.request(url).responseRSS() { (response) -> Void in
//                if let feed: RSSFeed = response.value {
//                    /// Do something with your new RSSFeed object!
//                    for item in feed.items {
//                        let article = NSMenuItem()
//                        let title = self.formatDate(item: item)
//
//                        //let article = NSMenuItem(title: title, action: #selector(self.openBrowser(urlSender:)), keyEquivalent: String(i))
//                        let someObj: NSString = item.link! as NSString
//                        article.representedObject = someObj
//                        article.action = #selector(self.openBrowser(urlSender:))
//                        article.title = title
//                        i+=1
//
//                        print(article.title)
//                        self.subMenu.addItem(article)
//                    }
//                }
//            }
           
           if let url = URL(string: urlString) {
               print(url)
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
           }
           else {
               print("CANNOT OPEN URL")
           }
        }

        
        categoryItem.submenu = self.subMenu
    }
    
    
    
    func update(urlString: String, CategoryItem: NSMenuItem) -> NSMenuItem {
        
        let url = URL(string: urlString)!
        let subMenu = NSMenu()
        var i = 0
//        let url: URL = URL(string: "https://m.sweclockers.com/feeds/forum/trad/999559")!

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

                    subMenu.addItem(article)
                }
            }
        }
        CategoryItem.submenu = subMenu
        return CategoryItem
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
//        for url in urls {
//            update(urlString: url)
//        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

