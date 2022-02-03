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



/*
 TODO
 Add different shade in menu item to indicate that it has been read
 Maybe add read notification to be saved between instances
 Add some window for a quick read of the rss description
 Add a setting window, that the user can choose the time interval in which the news should be displayed.
 
 */


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var statusBarMenu = NSMenu()
    
    private var refreshItem = NSMenuItem()
    private var quitItem = NSMenuItem()

    
    private var outlines = [Outline]()
    
    private let iconGroup = DispatchGroup()
    
    private var latestCopy = [String]()
    
    private let fontsize: CGFloat = 12

    private var articlesCopy = [Article]()
    var usedTitle = [String]()
    

    @IBOutlet weak var sourceTableView: NSTableView!
    
    private var latest = [Article]()
    

    
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
    
    /// Gets the icon for each source and stores it in a list.
    fileprivate func loadIcons() {
        for out in outlines {
            Task {
                iconGroup.enter()
                do {
                    if !imageExist(out.title) {
                        let icon = try await self.getFavicon(html: out.html)
//                      icons[out.title] = icon
                        saveImage(out.title, icon)
                    }
                }
                catch {
                    print("No image was found \(error)")
                }
                iconGroup.leave()
            }
        }
    }
    
     
    /// Quits the program
    @objc func quit () {
        exit(0)
    }
    

    
    /// Creates the submenu and menuitems. Only the basic structure, no feeds nor articles
    func createMenu() {
        self.statusBarMenu = NSMenu()
        
        // Creates a item to Quit the program
//        self.quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        
        self.quitItem.attributedTitle = useCustomFont(title: "Quit")
        self.quitItem.action = #selector(quit)
        self.quitItem.keyEquivalent = "q"
        
        
        // Creates a NSMenuItem to handle the RSS refresh
        self.refreshItem = NSMenuItem()
//        self.refreshItem.title = "Refresh"
        self.refreshItem.attributedTitle = useCustomFont(title: "Refresh")
        self.refreshItem.action = #selector(refresh)
        self.refreshItem.keyEquivalent = "r"
        self.refreshItem.target = self
    }
    
    func useCustomFont(title: String) -> NSMutableAttributedString {
    
        
        let font = NSFont(name: "OpenSans-Regular", size: fontsize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 5.0
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
//            print("URL of Favicon: \(favicon.url)")
        
//        return NSMutableAttributedString(string: title, attributes: [.font : font])
        return NSMutableAttributedString(string: title, attributes: attributes)
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
    
    /// Parses the html and finds the favicon using FaviconFinder
    ///
    ///  - Parameters:
    ///     html - The link of the website
    ///
    ///   - Returns:Icon from the website
    func getFavicon(html: String) async throws -> NSImage {
        let iconUrl = URL(string: (html))!
        do {
            let favicon = try await FaviconFinder(url: iconUrl).downloadFavicon()
//            print("URL of Favicon: \(favicon.url)")
            return favicon.image
        } catch {
            throw FaviconError.failedToFindFavicon
        }
    
    }
    
    
    /// Creates a NSMenuItem and asignes it a title with a
    ///  - Parameters:
    ///     article - Article from one RSS source
    ///  - Returns: Menu item containing the article with link
    fileprivate func createArticleItem(_ article: Article) -> NSMenuItem {
        let articleItem = NSMenuItem()
        
        let someObj: NSString = article.link as NSString
        articleItem.representedObject = someObj
        articleItem.action = #selector(self.openBrowser(urlSender:))
        
        
        var title = shortenText(item: article.title)
        title = title + " " + article.time
//        articleItem.title = title
        articleItem.attributedTitle = useCustomFont(title: title)

        
        self.iconGroup.notify(queue: .main) {
//            articleItem.image = self.icons[article.source]
//            articleItem.image?.size = CGSize(width: 15, height: 15)
            guard let image = loadImage(article.source) else {
                return
            }
            articleItem.image = image
            articleItem.image?.size = CGSize(width: 15, height: 15)
        }
        
        return articleItem
    }
    
    /// Adds an empty item to indicate that the news are too old
    fileprivate func addEmptyItem(_ sub: NSMenu) -> NSMenu {
        if sub.items.isEmpty {
            let empty = NSMenuItem()
            empty.title = "No new news found"
            sub.addItem(empty)
        }
        return sub
    }
    
    /// Displays the latest news in a notification from each category
    fileprivate func showNotifications(latest: [Article], used: [String]) {
        DispatchQueue.global().async {
            for late in latest {
                if !self.usedTitle.contains(late.title) {
//                    print("Visar notis för \(late.title)")
                    notifyUser(article: late)
                    self.usedTitle.append(late.title)
                    sleep(2)
                }
            }
            self.latestCopy = used
        }
    }
    
    ///Used to read the RSS. Is called when the user presses the "Refresh item"
    @objc func refresh() {
        self.statusBarMenu.removeAllItems()
        createMenu()
        var articles = [Article]()
        var categories = [String]()
        let group = DispatchGroup()

        
        var used = [String]()
        

        for out in outlines {
            group.enter()
                
            let url = URL(string: out.xmlUrl)!
            
            let category = out.category
            categories.append(category)
                
            AF.request(url).responseRSS() { [weak self] (response) -> Void in
                if (response.error != nil) {
                    self?.statusBarMenu.removeAllItems()
                    notfiyOffline()
                    let offlineItem = NSMenuItem()
                    offlineItem.attributedTitle = self?.useCustomFont(title: "No news found")
                    self?.statusBarMenu.addItem(offlineItem)
                    self?.statusBarMenu.addItem(self!.quitItem)
                    self?.statusBarMenu.addItem(self!.refreshItem)
                    self?.statusItem?.menu = self?.statusBarMenu
                    return
                }
                if let feed: RSSFeed = response.value {
                    for item in feed.items {
                        let time: Int = filterTime(date: item.pubDate ?? Date.now)
            
                        if time != 0 {
                            let article = createArticle(item, out, time)
                            articles.append(article)
                        }
                    }
                }
                group.leave()
            }
        }
        

        group.notify(queue: .main) {
            self.latest = [Article]()

            let uniqueCategories = self.uniqueSet(source: categories)
            articles = articles.sorted(by: {$0.date.compare($1.date) == .orderedDescending})

            for uC in uniqueCategories {
                let categoryItem = NSMenuItem()
                var sub = NSMenu()
//                categoryItem.title = uC
                categoryItem.attributedTitle = self.useCustomFont(title: uC)
                for article in articles {
                    if article.category.elementsEqual(categoryItem.title) {
                        if !used.contains(article.category) {
                            used.append(article.category)
                            self.latest.append(article)
                        }
                        let articleItem = self.createArticleItem(article)
                        
                        sub.addItem(articleItem)
                    }
                }
                sub = self.addEmptyItem(sub)
                
                categoryItem.submenu = sub
                categoryItem.target = self
                self.statusBarMenu.addItem(categoryItem)
                self.statusItem?.menu = self.statusBarMenu
                
          
//                notifyUser(categoryTitle: articles[i].category, articleTitle: articles[i].title, source: articles[i].source)
                
            }
            self.showNotifications(latest: self.latest, used: used)
            if self.usedTitle.count > 100 {
                let titleCopy = self.usedTitle
                self.usedTitle = [String]()
                self.usedTitle = Array(titleCopy.prefix(upTo: 5))
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
        
        
        articlesCopy = articles
       
    }
    
    /// Removes duplicate items from a set
    ///  - Parameters:
    ///     source - The set containing duplicates
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
    

    

    
    private func convert(minutes: Int) -> (hours: Int, minutes: Int) {
        return ((minutes % 3600) / 60, (minutes % 3600) % 60)
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

//extension AppDelegate: NSTableViewDataSource {
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return self.outlines.count ?? 0
//    }
//}

//extension AppDelegate: NSTableViewDelegate {
//
//  fileprivate enum CellIdentifiers {
//    static let NameCell = "SourcesID"
//  }
//
//
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//
//        var image: NSImage?
//        var text: String = ""
//        var cellIdentifier = ""
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .long
//
//        // 1
//        guard outlines[row] != nil else {
//          return nil
//        }
//
//        // 2
//        if tableColumn == tableView.tableColumns[0] {
//            print("tom")
//            cellIdentifier = CellIdentifiers.NameCell
//        }
//
//        // 3
////        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
////          cell.textField?.stringValue = text
////          return cell
////        }
//
//
//
//
//        return nil
//      }
//
//}



extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Dirty solution on opening a link from the selected notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        for article in latest {
            if article.category == response.notification.request.content.title {
                switch response.actionIdentifier {
                case "Open":
                    ActionHandler.sharedActionHandler.open(link: article.link)
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let application = NSApplication.shared
        
        if(application.isActive){
          print("user tapped the notification bar when the app is in foreground")
            application.setActivationPolicy(.accessory)
          
        }
        
        if(!application.isActive)
        {
          print("user tapped the notification bar when the app is in background")
            application.setActivationPolicy(.accessory)
        }
        
        /* Change root view controller to a specific viewcontroller */
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerStoryboardID") as? ViewController
        // self.window?.rootViewController = vc
        
        return completionHandler(.list)
    }
}


