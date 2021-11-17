//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation


public struct Outline {
    var title = ""
    var html = ""
    var xmlUrl = ""
    var icon = ""
}


public struct Category {
    var title = ""
    var numberOf: Int = 0
    var outlines = [Outline]()
  
}



class OPMLReader {
    
    func readOPML() -> [Category]  {
        var categories = [Category]()
        
        let xmlPath = Bundle.main.path(forResource: "Subscriptions", ofType: "xml")
        if xmlPath == nil {
            NSLog("Failed to find Subscription file")
        }
        let url1 = URL(fileURLWithPath: xmlPath!) 
        do {
            let data = try Data(contentsOf: url1)
            let parser = XMLParser(data: data)
            let parserBase = ParserBase()
            parser.delegate = parserBase
     
     
            
            
            
            parser.parse()
            categories = parserBase.getCategories()
            
        
            

//            for item in category.items {
//                print("item = \(item.title) \(item.xmlUrl) \(item.html)")
//            }
        }
        catch {
            NSLog("Failed to parse opml file")
        }
        return categories
    }
}

