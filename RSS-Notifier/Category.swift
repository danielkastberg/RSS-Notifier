//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-30.
//

import Foundation


class Category: ParserBase {
    
    var title = ""
    
    var count = 0
    var items = [Item]()
    var numberOfCategories = 0

    override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {

        // if we found a marker tag, delegate further responsibility
        // to parsing to a new instance of Marker

        if elementName == "category" {
            numberOfCategories += 1
            title = attributeDict["title"]!
            print("category title = " + title)
            let item = Item()
            items.append(item)
            
            

            // push responsibility
            parser.delegate = item

            // let marker know who we are
            // so that once marker is done XML processing
            // it can return parsing responsibility back
            item.parent = self
        }
    }
}







