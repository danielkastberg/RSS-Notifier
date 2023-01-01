//
//  AppDelegate.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire
import UserNotifications



/*
 TODO
 Add different shade in menu item to indicate that it has been read
 Maybe add read notification to be saved between instances
 Add some window for a quick read of the rss description
 Add a setting window, that the user can choose the time interval in which the news should be displayed.
 Fix bug when one news source fail. If one news source fail, no sotring of time is made 
 
 */
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var statusBarMenu = NSMenu()
    
    private var windowController: NSWindowController!

    private var outlines = [Outline]()
    
    private let iconGroup = DispatchGroup()
    
    private var latestCopy = [String]()
    private var articlesCopy = [Article]()
    private var usedTitle = [String]()
    
    private var latest = [Article]()
    
    private var offlineIcon = false

    private var articles = [Article]()
    private var categories = [String]()
    private let group = DispatchGroup()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlines = OPMLHandler().readOPML()
        
        loadIcons()
        
        if !outlines.isEmpty {
            refresh()
        }
        else {
            emptyMenu(message: "No news source found")
        }

        loadAppIcon(offline: false)
    }
    
    /// Gets the icon for each source and stores it in a list.
    fileprivate func loadIcons() {
        for out in outlines {
            Task {
                iconGroup.enter()
                do {
                    if !imageExist(out.title) {
                        let icon = try await getFavicon(html: out.html)
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
    
    @objc func openSettings() {
        if windowController != nil {
            windowController.close()
        }
        let mainStoryBoard = NSStoryboard(name: "Main", bundle: nil)
        
        windowController = mainStoryBoard.instantiateController(withIdentifier: "settings") as? NSWindowController
        // Move the window to the top of all windows
        windowController.window?.orderFrontRegardless()
    }

    

    /// Creates a NSMenuItem to quit the program
    ///  - Returns The menu item for quitting the program
    private func createQuitItem() -> NSMenuItem {
        let quitItem = NSMenuItem()
        quitItem.attributedTitle = useCustomFont(title: "Quit")
        quitItem.action = #selector(quit)
        quitItem.keyEquivalent = "q"
        quitItem.target = self
        return quitItem
    }
    
    /// Creates a NSMenuItem to open the settings view
    ///  - Returns The menu item for the settings
    private func createSettingsItem() -> NSMenuItem {
        let settingItem = NSMenuItem()
        settingItem.attributedTitle = useCustomFont(title: "Settings")
        settingItem.keyEquivalent = "s"
        settingItem.action = #selector(openSettings)
        settingItem.target = self
        return settingItem
    }
    
    /// Creates a NSMenuItem to handle the RSS refresh
    /// ///  - Returns The menu item for refreshing the program
    fileprivate func createRefreshItem() -> NSMenuItem {
        let refreshItem = NSMenuItem()
        refreshItem.attributedTitle = useCustomFont(title: "Refresh")
        refreshItem.action = #selector(refresh)
        refreshItem.keyEquivalent = "r"
        refreshItem.target = self
        return refreshItem
    }
    
    /// Creates the submenu and menuitems. Only the basic structure, no feeds nor articles
    private func createStaticItems() {
        self.statusBarMenu.addItem(createQuitItem())
        self.statusBarMenu.addItem(createSettingsItem())
        self.statusBarMenu.addItem(createRefreshItem())
    }
    
    /// Adds the options to the menu. Will be added independent if there is any news sources found
    private func createMenu() -> NSMenu {
        let statusBarMenu = NSMenu()
        self.statusBarMenu.addItem(createSettingsItem())
        self.statusBarMenu.addItem(createQuitItem())
        self.statusBarMenu.addItem(createRefreshItem())
        return statusBarMenu
    }
    
    /// Creates an empty menu. Used if the user is offline.
    private func emptyMenu(message: String) {
        self.statusBarMenu = NSMenu()
        let offlineItem = NSMenuItem()
        offlineItem.attributedTitle = useCustomFont(title: message)
        self.statusBarMenu.addItem(offlineItem)
        createStaticItems()
        statusItem.menu = self.statusBarMenu
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
        articleItem.attributedTitle = useCustomFont(title: title)

        
        self.iconGroup.notify(queue: .main) {
            guard let image = openImage(article.source) else {
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

    /// Checks if there is an image to use as icon, If not loads a title instead
    private func loadAppIcon(offline: Bool) {
        DispatchQueue.main.async {
            if offline {
                guard let image = NSImage(named: "Error") else {
                    self.statusItem.button?.title = "RSS Notifier"
                    return
                }
                image.isTemplate = true
                image.size = CGSize(width: 19, height: 19)
                self.statusItem.button?.image = image
                self.offlineIcon = true
            }
            else {
                guard let image = NSImage(named: "AppIcon") else {
                    self.statusItem.button?.title = "RSS Notifier"
                    return
                }
                image.isTemplate = true
                image.size = CGSize(width: 19, height: 19)
                self.statusItem.button?.image = image
            }
        }
    }
    
    ///Used to read the RSS. Is called when the user presses the "Refresh item"
    @objc func refresh() {
        self.statusBarMenu.removeAllItems()
//        let eventTracking: RunLoop.Mode

        if outlines.isEmpty {
            emptyMenu(message: "No news source found")
            return
        }

        fetchRSS()
        insertRSS()

        
        if self.offlineIcon == true {
            loadAppIcon(offline: false)
        }
        
        articlesCopy = articles
    }

    private func fetchRSS() {
        for out in outlines {
            group.enter()

            guard let url = URL(string: out.rss) else {
                emptyMenu(message: "Error found in OPML file. Check sources")
                return
            }

            let category = out.category
            categories.append(category)

            AF.request(url).responseRSS() { [weak self] (response) -> Void in
                if (response.error != nil) {
                    self?.statusBarMenu.removeAllItems()
                    notfiyOffline()
                    self?.loadAppIcon(offline: true)
                    self?.emptyMenu(message: "No news found")
                    return
                }
                if let feed: RSSFeed = response.value {
                    for item in feed.items {
                        let time: Int = filterTime(date: item.pubDate ?? Date.now)

                        if time > 0 {
                            let article = createArticle(item, out, time)
                            self?.articles.append(article)
                        }
                    }
                }
                self?.group.leave()
            }
        }
    }

    private func insertRSS() {
        var used = [String]()

        group.notify(queue: .main) {
            self.latest = [Article]()

            let uniqueCategories = self.uniqueSet(source: self.categories)
            self.articles = self.articles.sorted(by: {$0.date.compare($1.date) == .orderedDescending})

            for uC in uniqueCategories {
                let categoryItem = NSMenuItem()
                var sub = NSMenu()
                categoryItem.attributedTitle = useCustomFont(title: uC)
                for article in self.articles {
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
                self.statusItem.menu = self.statusBarMenu


//                notifyUser(categoryTitle: articles[i].category, articleTitle: articles[i].title, source: articles[i].source)

            }
            self.showNotifications(latest: self.latest, used: used)
            if self.usedTitle.count > 100 {
                let titleCopy = self.usedTitle
                self.usedTitle = [String]()
                self.usedTitle = Array(titleCopy.prefix(upTo: 5))
            }

            self.statusBarMenu.addItem(self.blankWidth())
            self.statusBarMenu.addItem(NSMenuItem.separator())

            self.statusBarMenu = self.createMenu()
        }
    }
    
    private func blankWidth() -> NSMenuItem {
        let frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 20))
        let lineView = NSView(frame: CGRect(x: 0, y: 100, width: 160, height: 1.0))
        let viewHint = NSView(frame: frame)
        viewHint.drawPageBorder(with: CGSize(width: 100, height: 20))
        viewHint.layer?.borderColor = CGColor.black

        let lineItem = NSMenuItem()
        lineItem.view = lineView
        return lineItem
        
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
    
    /// Opening a link from the selected notification.
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
//        let application = NSApplication.shared
//
//        for article in latest {
//            if article.category == notification.request.content.title {
//                print(notification.request.identifier)
//                guard let url = URL(string: article.link as! String) else {
//                    return
//                }
//                NSWorkspace.shared.open(url)
//            }
//        }
//
//        return completionHandler(.list)
    }
}


