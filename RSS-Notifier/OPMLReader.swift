//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation

let subscriptions = "Subscriptions"
let type = "xml"

public struct Outline {
    var title = ""
    var html = ""
    var xmlUrl = ""
    var icon = ""
    var category = ""
}


public struct Category {
    var title = ""
    var numberOf: Int = 0
    var outlines = [Outline]()
  
}



class OPMLReader {
    
    func readOPML() -> [Outline]  {
        var outlines = [Outline]()
        
        let xmlPath = Bundle.main.path(forResource: subscriptions, ofType: type)
        if xmlPath == nil {
            NSLog("Failed to find Subscription file")
        }
        let url = URL(fileURLWithPath: xmlPath!)
        do {
            let data = try Data(contentsOf: url)
            let parser = XMLParser(data: data)
            let parserBase = ParserBase()
            parser.delegate = parserBase

            parser.parse()
            outlines = parserBase.getOutlines()
            

//            for item in category.items {
//                print("item = \(item.title) \(item.xmlUrl) \(item.html)")
//            }
        }
        catch {
            NSLog("Failed to parse opml file")
        }
        return outlines
    }
    
    
    func writeOPML() {
        
    }
}

