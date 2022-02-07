//
//  ViewController.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-11-01.
//

import Cocoa
//@objcMembers private class OutlineClass: NSObject {
//    var title = ""
//    var html = ""
//    var xmlUrl = ""
//    var icon = ""
//    var category = ""
//}

class ViewController: NSViewController {
    
    private var outlines = [Outline]()
//    private var outlineClass = [OutlineClass]()
    
    @IBOutlet var tableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let oplmR = OPMLReader()
        outlines = oplmR.readOPML()
//        convertOutline(outlines: outlines)
        
        
        // reload tableview
        tableView.reloadData()
    }
//    private func convertOutline(outlines: [Outline]) {
//        for outline in outlines {
//            let outC = OutlineClass()
//            outC.title = outline.title
//            outC.xmlUrl = outline.xmlUrl
//            outC.category = outline.category
//            self.outlineClass.append(outC)
//        }
//    }
    
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
    
    
    // I think I have to change something here
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let personsAsMutableArray = NSMutableArray(array: outlines)
        personsAsMutableArray.sort(using: tableView.sortDescriptors)
        outlines = personsAsMutableArray as! [Outline]
        tableView.reloadData()
    }
}
