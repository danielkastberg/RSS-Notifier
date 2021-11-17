//
//  AppDelegate.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire

// Prova OPML bibliotek och se om det blir snabbare eller mer tillförlitigligt.
// Kan även behöva se över en HTML parser
// Lutar mer och mer att jag provar med ett färdigt biblitotek
// så jag kan fokusera på skolan och alla andra grupprpjekt.
// Spara det här isf på en egen branch så finns det kvar om jag vill jobba vidare
// eller visa upp eller kolla tillbaka

/*
 TODO
 Add notification support
 Add different shade in menu item to indicate that it has been read
 Maybe add read notification to be saved between instances
 Add some window for a quick read of the rss description
 Add a setting window, that the user can choose the time interval in which the news should be displayed.
 Change the font and size on the text displayed.
 Fix text formatting
 Sort items after date
 
 Look into threads (DispatchQueue) and if I can avoid running everything from "awakeFronNib"
 Maybe get to load the RSS in a thread and then fill the menu Item. Don't know how much the program will gain on it since
 I will still recreate the menuitems but to not clutter the memory and it will be more cpu consuming searching through
 the articles and filter than simply recreate everything. Masybe it will be more thread safe than the current situation.
 
 Try an clean up the code and refactor it. If it gets to overwhelming maybe start from the beginning since now I actually have some knowledge.
 
 */

public struct menuItem {
    var title = ""
    var date = Date()
}


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?

    var statusBarMenu = NSMenu()
    var subMenu = NSMenu()
    
    let refreshItem = NSMenuItem()
    let categoryItem = NSMenuItem()
    
    var listOfCategories = [NSMenuItem]()
    
    var categories = [Category]()
    
    var outlines = [Outline]()
    
    
    // How old news that should be displayed in minutes.
    var timeIntervalNews = 1440
    
    var urls = [""]
    

    
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let oplmR = OPMLReader()
        categories = oplmR.readOPML()
        

        
        
//        let categories = category.getCategories()
        
        
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        

        
        // Checks if there is an image to use as icon.
        // If not loads a title instead
        if let image = NSImage(named: "AppIcon") {
            image.isTemplate = true
            image.size = CGSize(width: 19, height: 19)
            statusItem?.button?.image = image
            refreshItem.title = "Refresh"
        }
        else {
            statusItem?.button?.title = "RSS Notifier"
        }
        
        
        
        
        
        
 
        
        
        // Creates a item to Quit the program
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        

        // Creates a NSMenuItem to handle the RSS refresh
        refreshItem.title = "Refresh"
        refreshItem.action = #selector(refresh)
        refreshItem.target = self
        
//        print(categories.indices)
//        var first = true
//        for out in outlines {
//            var sub = NSMenu()
//            var articleItem = NSMenuItem()
//            var categoryItem = NSMenuItem()
//            if out.xmlUrl == "" {
//                if first == true {
//                    categoryItem.title = out.title
//                    first = false
//                }
//                else {
//
//                    categoryItem.title = out.title
//
//                }
//            }
//            else {
//                articleItem.title = out.title
//                urls.append(out.xmlUrl)
//                categoryItem = laodRss(outline: out, categoryItem: categoryItem)
////                sub.addItem(categoryItem)
//            }
//            categoryItem.target = self
//            print(categoryItem.title)
//            statusBarMenu.addItem(categoryItem)
//            categoryItem.menu?.setSubmenu(sub, for: articleItem)
//            statusItem?.menu = statusBarMenu
//        }
        
        
        for i in 0...categories.endIndex-1 {
            var categoryList = [NSMenuItem]()
         
            var sub = NSMenu()
            var categoryItem = NSMenuItem()
            var articleItem = NSMenuItem()
            categoryItem.title = categories[i].title
            
            for outline in categories[i].outlines {
                let sub = laodRss(outline: outline, subMenu: sub)
                
                print(sub.items)
            }
            categoryItem.submenu = sub
            categoryItem.target = self
            statusBarMenu.addItem(categoryItem)
            statusItem?.menu = statusBarMenu
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    
    /*
     Quits the program
     */
    @objc func quit () {
        exit(0)
    }
    
           
    /*
     Used to read the RSS. Is called when the user presses the "Refresh item"
     */
    @objc func refresh() {
//        let urlString = urls.representedObject
//        let url = URL(string: urlString as! String)!
        self.subMenu = NSMenu()
 
    
        statusBarMenu = NSMenu()
//
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        
        let refreshItem = NSMenuItem()
//
//
        // Creates a NSMenuItem to handle the RSS refresh
        refreshItem.title = "Refresh"
        refreshItem.action = #selector(refresh)
        refreshItem.target = self



        
//        let categories = category.getCategories()
//        for c in categories {
//            var categoryItem = NSMenuItem()
//            categoryItem.title = c.title
//            for outline in c.items {
//                urls.append(outline.xmlUrl)
//                categoryItem = laodRss(urlString: outline.xmlUrl, htmlString: outline.html, categoryItem: categoryItem)
//            }
//            categoryItem.target = self
//            statusBarMenu.addItem(categoryItem)
//            statusItem?.menu = statusBarMenu
//        }
        
        
        for i in 0...categories.endIndex-1 {
            var categoryList = [NSMenuItem]()
         
            var sub = NSMenu()
            var categoryItem = NSMenuItem()
            var articleItem = NSMenuItem()
            categoryItem.title = categories[i].title
            
            for outline in categories[i].outlines {
                let sub = laodRss(outline: outline, subMenu: sub)
                
                print(sub.items)
            }
            categoryItem.submenu = sub
            categoryItem.target = self
            statusBarMenu.addItem(categoryItem)
            statusItem?.menu = statusBarMenu
        }
        
        statusBarMenu.addItem(quitItem)
        statusBarMenu.addItem(refreshItem)
    }
    
    
    
    func laodRss(outline: Outline, subMenu: NSMenu) -> NSMenu {
        var articleList = [NSMenuItem]()

        let url = URL(string: outline.xmlUrl)!
    

        AF.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.value {
                /// Do something with your new RSSFeed object!
                for item in feed.items {

                    let article = NSMenuItem()
                    let timeString = self.formatDate(item: item)
                    if timeString != "" {
                        var tit = ""
                        let stringLength = 40
                       
                        if item.title!.count > stringLength {
                            tit = item.title!
                            for _ in stringLength...tit.count {
                                tit.remove(at: tit.index(before: tit.endIndex))
                            }
                            tit.append("...")
                          
                        }
                        else {
                            tit = item.title!
                        }
                        let title = tit + "  " + timeString
//                        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 12)])
//                        let test = attributedString.string
                        let someObj: NSString = item.link! as NSString
//                        article.attributedTitle = attributedString
                        
                        article.representedObject = someObj
                        article.action = #selector(self.openBrowser(urlSender:))
                        article.title = title

                        //// Get the url from the article and add /favicon.ico to get the image
                        /// Will add the image to each article to indicate the source
                        let url = URL(string: outline.icon)

                        self.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
//                            print(response?.suggestedFilename ?? url!.lastPathComponent)
//                            print("Download Finished")
                            //// always update the UI from the main thread
                            DispatchQueue.main.async() { [weak self] in
                                article.image = NSImage(data: data)
                                article.image?.size = CGSize(width: 15, height: 15)
//                                print("Image loaded")
                            }
                        }
                        subMenu.addItem(article)
                    }
                }
            }
        }
//        categoryItem.submenu = subMenu
        return subMenu
    }
    
    /*
     Opens the browser for the link that is sent.
     Used to open a link from one article
     */
    @objc func openBrowser(urlSender: NSMenuItem) {
        let urlString = urlSender.representedObject
        guard let url = URL(string: urlString as! String) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    /*
     Formats the time and calculates how long ago the article was published from the current time.
     Also filters away too old news
     */
    func formatDate(item: RSSItem) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd, HH:mm"
        let timeSincePub = Date().timeIntervalSince(item.pubDate!)
        let timeSincePubInMin = Int(timeSincePub) / 60
        
        if timeSincePubInMin < timeIntervalNews {
            let time = calculateTime(minutesSincePub: timeSincePubInMin)
//            let title = item.title! + "\t" + String(time)
            return time
        }
        else {
            return ""
        }
  
        
        
//        let dateStr = dateFormatter.string(from: item.pubDate!)
        // let title = item.title! + "\t" + dateStr
        
    
    }
    /*
     Calculates the time and puts it into a string to be used next to the title
     Formats the time to ex, 1h 24 min instead of 84 min
     */
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

