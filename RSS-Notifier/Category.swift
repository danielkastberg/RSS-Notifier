//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-30.
//

import Foundation


class Category: ParserBase {
    var cs = CategoryStruct()
    var title = ""
    var items = [Outline]()
    var numberOf: Int = 0
    var categories = [CategoryStruct]()

    override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {

        // if we found a marker tag, delegate further responsibility
        // to parsing to a new instance of Marker

        if elementName == "category" {
            cs.numberOf += 1
            cs.title = attributeDict["title"]!
        
            
            numberOf += 1
            title = attributeDict["title"]!
            print("category title = " + title)
            let item = Outline()
            items.append(item)
            cs.items.append(item)
            categories.append(cs)


            

            // push responsibility
            parser.delegate = item

            // let marker know who we are
            // so that once marker is done XML processing
            // it can return parsing responsibility back
            item.parent = self
        }
    }
    
    func getCategories() -> [CategoryStruct] {
        return categories
    }
}







