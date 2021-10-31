//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-30.
//

import Foundation
import AppKit


class Channel: ParserBase {
    
    var count = 0
    var items = [Item]()

    override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {

        print("processing <\(elementName)> tag from channel")

        if elementName == "channel" {

            // if we are processing a coord2 tag, we are at the root
            // of this example
            // extract the count value and set it
        }

        // if we found a marker tag, delegate further responsibility
        // to parsing to a new instance of Marker

        if elementName == "item" {
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







