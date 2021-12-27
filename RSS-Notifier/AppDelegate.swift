//
//  AppDelegate.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire
import UserNotifications
import FaviconFinder


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

public struct Articles {
    var title = ""
    var date = Date()
    var link = ""
    var icon = ""
    var category = ""
    var timeSincePubInMin = 0
    var timeString = ""
    var source = ""
    var isClicked = false
}




@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    
    var statusItem: NSStatusItem?

    
    var statusBarMenu = NSMenu()
    
    
    var refreshItem = NSMenuItem()
    var quitItem = NSMenuItem()

    
    var outlines = [Outline]()
    
    var icons = [String: NSImage]()
    
    let iconGroup = DispatchGroup()
    
    
    //// Sets a limit on how old the news are allowerd to be. In minutes
    let timeIntervalNews = 1440
    
    
    
    
  
    fileprivate func loadIcons() {
        for out in outlines {
            Task {
                iconGroup.enter()
                let icon = await self.getFavicon(html: out.html)
                icons[out.title] = icon
                iconGroup.leave()
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        let oplmR = OPMLReader()
        outlines = oplmR.readOPML()
        
        loadIcons()
        
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        

        refresh()
        loadAppIcon()
  
        
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
    

    
    /// Creates the submenu and menuitems. Only the basic structure, no feeds or articles
    func createMenu() {
        
        
        self.statusBarMenu = NSMenu()
        
        // Creates a item to Quit the program
        self.quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        

        // Creates a NSMenuItem to handle the RSS refresh
        self.refreshItem = NSMenuItem()
        self.refreshItem.title = "Refresh"
        self.refreshItem.action = #selector(refresh)
        self.refreshItem.target = self
    }
    
    
    
    /// Checks if there is an image to use as icon, If not loads a title instead
    func loadAppIcon() {
        DispatchQueue.main.async {
            guard let image = NSImage(named: "AppIcon") else {
                self.statusItem?.button?.title = "RSS Notifier"
                return
            }
            image.isTemplate = true
            image.size = CGSize(width: 19, height: 19)
            self.statusItem?.button?.image = image
            self.refreshItem.title = "Refresh"
        }

    }
    
    func getFavicon(html: String) async -> NSImage{

        let iconUrl = URL(string: (html))!
        do {
            let favicon = try await FaviconFinder(url: iconUrl).downloadFavicon()
            print("URL of Favicon: \(favicon.url)")
            return favicon.image
        } catch {
            print(FaviconError.emptyFavicon.localizedDescription)
        }


        return NSImage(byReferencingFile: "icon.png")!


    }
    
    
           
    
     ///Used to read the RSS. Is called when the user presses the "Refresh item"
    @objc func refresh() {
        createMenu()
        var RSSItems = [RSSItem]()
        
        var articles = [Articles]()
        
        var categories = [String]()
        
        let group = DispatchGroup()
        
     
        
        
        
        for i in 0 ... outlines.endIndex-1 {
            group.enter()
                
            let url = URL(string: outlines[i].xmlUrl)!
            

            let category = outlines[i].category
            categories.append(category)
                
            AF.request(url).responseRSS() { [weak self] (response) -> Void in
                if let feed: RSSFeed = response.value {
//                    print(feed.link)
                    for item in feed.items {
                        let time: Int = self?.filterTime(date: item.pubDate ?? Date.now) ?? 0
            
                        if time != 0 {
                            var art = Articles()
                            
                            art.title = item.title ?? ""
                            art.link = item.link ?? ""
                            art.icon = self?.outlines[i].html ?? ""
                            art.date = item.pubDate ?? Date.now
                            art.timeString = self?.calculateTime(minutesSincePub: time) ?? ""
                            art.category = category
                            art.source = (self?.outlines[i].title) ?? ""
                            
                            
                            articles.append(art)
                        }
                    }
                }
                group.leave()
            }
            
        }
        
        group.notify(queue: .main) {
//            let unique = Array(Set(categories))
            let unique = self.uniqueSet(source: categories)
            articles = articles.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
            

            
            for i in 0 ... unique.endIndex-1 {
                let categoryItem = NSMenuItem()
                let sub = NSMenu()
                categoryItem.title = unique[i]
                for article in articles {
//                    print(article.title + " " + article.timeString)
                    if article.category.elementsEqual(categoryItem.title) {
                        let articleItem = NSMenuItem()
                        let someObj: NSString = article.link as NSString
                        articleItem.representedObject = someObj
                        articleItem.action = #selector(self.openBrowser(urlSender:))
                        var title = self.shortenText(item: article.title)
                        title = title + " " + article.timeString
                        articleItem.title = title
                        
                        
                        self.iconGroup.notify(queue: .main) {
                            articleItem.image = self.icons[article.source]
                            articleItem.image?.size = CGSize(width: 15, height: 15)
                        }
                        
                        sub.addItem(articleItem)

                    }
                }
                categoryItem.submenu = sub
                categoryItem.target = self
                self.statusBarMenu.addItem(categoryItem)
                self.statusItem?.menu = self.statusBarMenu
                
          
                notifyUser(categoryTitle: articles[i].category, articleTitle: articles[i].title, source: articles[i].source)
                
            }
            let frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 20))
            let lineView = NSView(frame: CGRect(x: 0, y: 100, width: 240, height: 1.0))
            let viewHint = NSView(frame: frame)
            viewHint.drawPageBorder(with: CGSize(width: 100, height: 20))
            viewHint.layer?.borderColor = CGColor.black

            let lineItem = NSMenuItem()
            lineItem.view = lineView
            self.statusBarMenu.addItem(lineItem)
   
            self.statusBarMenu.addItem(self.quitItem)
            self.statusBarMenu.addItem(self.refreshItem)

                    
            
        }
    }
    
    func uniqueSet<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
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
    func formatDate(date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd, HH:mm"
        let timeSincePub = Date().timeIntervalSince(date)
        let timeSincePubInMin = Int(timeSincePub) / 60
        
        if timeSincePubInMin < timeIntervalNews {
            let time: String = calculateTime(minutesSincePub: timeSincePubInMin)
//            let title = item.title! + "\t" + String(time)
            return time
        }
        else {
            return ""
        }
    }
    

    
    private func convert(minutes: Int) -> (hours: Int, minutes: Int) {
        return ((minutes % 3600) / 60, (minutes % 3600) % 60)
    }

    
    func filterTime(date: Date) -> Int {
        let timeSincePub = Date().timeIntervalSince(date)
        let timeSincePubInMin = Int(timeSincePub) / 60
        

        if timeSincePubInMin < timeIntervalNews {
            
            
            return timeSincePubInMin
        }
        else {
            return 0
        }
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
    
    /*
     If the title of the article is to long the functions cut it of after 40 char
     and adds thre dots ... to indicate that the full title isn't showing
     */
    func shortenText(item: String) -> String {
        var title = ""
        let stringLength = 40
       
        if item.count > stringLength {
            title = item
            for _ in stringLength...title.count {
                title.remove(at: title.index(before: title.endIndex))
            }
            title.append("...")
          
        }
        else {
            title = item
        }
        return title
        
    }
 
    
    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        un.delegate = self


    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}



extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        return completionHandler(.list)
    }
}
