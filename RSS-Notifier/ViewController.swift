//
//  ViewController.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa

class ViewController: NSViewController {
    
    private var outlines = [Outline]()
    
    @IBOutlet var tableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let oplmR = OPMLReader()
        outlines = oplmR.readOPML()
        
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
        
        if let cell =  tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            return cell
        }
        
        
        return nil
    }
    
    func filterList() {
        outlines.sorted{$0.title > $1.title}
    }
}
