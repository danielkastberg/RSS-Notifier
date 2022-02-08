//
//  ViewController.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire


protocol SourceVCDelegate : NSObjectProtocol{
    func doSomethingWith(data: [Outline])
}

class ViewController: NSViewController {
    
    private var outlines = [Outline]()
//    private var outlineClass = [OutlineClass]()
    
    private let oplmR = OPMLHandler()
    @IBOutlet var tableView: NSTableView!
    /// Removes the selected source from the list of outlines.
    /// Also removes it from the Subscriptions XML
    @IBAction func removeSource(_ sender: Any) {
        let selectedItem = tableView.selectedRow
        if selectedItem < 0 {
            return
        }
        let title = outlines[selectedItem].title
        let category = outlines[selectedItem].category
        let link = outlines[selectedItem].rss
        
        for outline in outlines {
            if title == outline.title && category == outline.category {
                outlines.remove(at: selectedItem)
            }
        }
        
        tableView.reloadData()
        
        oplmR.writeOPML(outlines)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlines = oplmR.readOPML()
//        outlineClass = opmlR.convertOutline(outlines: outlines)
        
        // reload tableview
        tableView.reloadData()
    }
    
//    override func viewWillAppear() {
//        outlines = oplmR.readOPML()
//        tableView.reloadData()
//    }

    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate, SourceVCDelegate {
    func doSomethingWith(data: [Outline]) {
        outlines = data
        oplmR.writeOPML(data)
        tableView.reloadData()
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (outlines.count)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = outlines[row]
        var text = ""
        var image: NSImage?
        
        // Get title and image
        if tableColumn == tableView.tableColumns[0] {
            text = item.title
            image = openImage(item.title)
        }
        // Get category
        if tableColumn == tableView.tableColumns[1] {
            text = item.category
        }
        // Get rss url
        if tableColumn == tableView.tableColumns[2] {
            text = item.rss
        }
        // Adds text to cell and image if it exists
        if let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            return cell
        }
        
        
        return nil
    }
    
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let personsAsMutableArray = NSMutableArray(array: outlines)
        personsAsMutableArray.sort(using: tableView.sortDescriptors)
        outlines = personsAsMutableArray as! [Outline]
        tableView.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if(segue.identifier == "sourceVC"){
            let displayVC = segue.destinationController as! addSourceVC
            displayVC.outlines = outlines
            displayVC.delegate = self
        }
    }
}



class addSourceVC: NSViewController, NSTextFieldDelegate {
    
    public var outlines: [Outline]?
    
    weak var delegate: SourceVCDelegate?
    
    
    @IBOutlet weak var categoryField: NSTextFieldCell!
    @IBOutlet weak var rssField: NSTextFieldCell!
    
    
    @IBAction func addSource(_ sender: Any) {
        let rss = rssField?.stringValue
        let urlR = URL(string: rss ?? "")
        if urlR == nil {
            let alert = NSAlert.init()
            alert.messageText = "Error!\n Invlid URL"
            alert.runModal()
            return
        }
        let url = URLRequest(url: urlR  ?? URL(string: "")!)
        
        AF.request(url).responseRSS() { [weak self] (response) -> Void in
            if (response.error != nil) {
                let alert = NSAlert.init()
                alert.messageText = "Error!\n Invlid URL"
                alert.runModal()
                return
            }
            let title = response.value?.title
            let html = response.value?.link
            
            let out = Outline()
            out.title = title ?? ""
            out.html = html ?? ""
            if out.html == "" {
                out.html = (self?.rssField.stringValue)!
            }
            if out.html.hasSuffix("rss") {
                out.html.removeLast(3)
            }
            else if out.html.hasSuffix(".rss") {
                out.html.removeLast(4)
            }
            print(out.html)
            out.rss = rss ?? ""
            out.category = self?.categoryField.stringValue ?? ""
            
            self?.outlines?.append(out)
            if let delegate = self?.delegate {
                delegate.doSomethingWith(data: (self?.outlines!)!)
            }
            let alert = NSAlert.init()
            if out.title != "" {
                alert.messageText = "Successfully added \(out.title)"
            }
            else {
                alert.messageText = "Successfully added \(out.rss)"
            }
        
            alert.runModal()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: NSTextField.textDidChangeNotification, object: nil)   
    }
    
    
    @objc func textDidChange(_ notification: Notification) {
        guard (notification.object as? NSTextField) != nil else { return }
        let rssUrl = rssField.stringValue
        let category = categoryField.stringValue
        let numberOfCharatersInTextfield: Int = rssField.accessibilityNumberOfCharacters()
        print(rssUrl)
        print(category)
        print("numberOfCharatersInTextfield = \(numberOfCharatersInTextfield)")
    }

}
