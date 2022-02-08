//
//  ViewController.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa

class ViewController: NSViewController {
    
    private var outlines = [Outline]()
//    private var outlineClass = [OutlineClass]()
    
    private let oplmR = OPMLReader()
    @IBOutlet var tableView: NSTableView!
    @IBAction func removeSource(_ sender: Any) {
        let selectedItem = tableView.selectedRow
        print(selectedItem)
        if selectedItem < 0 {
            return
        }
        let title = outlines[selectedItem].title
        let category = outlines[selectedItem].category
        let link = outlines[selectedItem].xmlUrl
        
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
    
}



extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (outlines.count)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = outlines[row]
        var text = ""
        var image: NSImage?
        
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.title
            image = loadImage(item.title)
        }
        if tableColumn == tableView.tableColumns[1] {
            text = item.category
        }
        
        if tableColumn == tableView.tableColumns[2] {
            text = item.xmlUrl
        }
        
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
}
