//
//  ViewController.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
import Alamofire


protocol SourceVCDelegate : NSObjectProtocol{
    func SaveOPMLReloadView(data: [Outline])
}

class SettingsVC: NSViewController {
    
    private var outlines = [Outline]()
    
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
        
        // reload tableview
        tableView.reloadData()
    }
}

extension SettingsVC: NSTableViewDataSource, NSTableViewDelegate, SourceVCDelegate {
    func SaveOPMLReloadView(data: [Outline]) {
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
    
    

    /// Adds a source from user input URL and adds to the loaded list of outlines
    /// Sends the list back to first ViewController
    @IBAction func addSource(_ sender: Any) {
        let rss = rssField?.stringValue
        let category = categoryField?.stringValue
        
        let urlR = URL(string: rss ?? "")
        if urlR == nil {
            self.showAlert(message: "Error!\n Invlid URL")
            return
        }
        let url = URLRequest(url: urlR  ?? URL(string: "")!)
        
        AF.request(url).responseRSS() { [weak self] (response) -> Void in
            if (response.error != nil) {
                self?.showAlert(message: "Error!\n Invlid URL")
                return
            }
            let title = response.value?.title
            let html = response.value?.link
            
            let out = Outline()
            out.title = title ?? ""
            out.html = self?.createHTMLattr(html: html ?? "", rss: rss ?? "") ?? ""
            out.rss = rss ?? ""
            out.category = category ?? ""
            
            self?.outlines?.append(out)
            if let delegate = self?.delegate {
                delegate.SaveOPMLReloadView(data: (self?.outlines!)!)
            }
         
            if out.title != "" {
                self?.showAlert(message: "Successfully added \(out.title)")
            }
            else {
                self?.showAlert(message: "Successfully added \(out.rss)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert(message: String) {
        let alert = NSAlert.init()
        alert.messageText = message
        alert.runModal()
    }
    
    private func createHTMLattr(html: String, rss: String) -> String {
        var outHtml = html
        if outHtml == "" {
            outHtml = rss
        }
        if outHtml.hasSuffix("rss") {
            outHtml.removeLast(3)
        }
        else if outHtml.hasSuffix(".rss") {
            outHtml.removeLast(4)
        }
        if !outHtml.starts(with: "https") {
            outHtml = "https:\(outHtml)"
        }
        return outHtml
    }

}
