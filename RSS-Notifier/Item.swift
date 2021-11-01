//
//  ItemParser.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation



class Item : ParserBase {
    
    var link:String = ""
    var desc:String = ""
    var title:String = ""
    var date: Date = Date()

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // if we finished an item tag, the ParserBase parent
        // would have accumulated the found characters
        // so just assign that to our item variable
        if elementName == "title" {
            self.title = foundCharacters
        }
        else if elementName == "link" {
            self.link = foundCharacters
        }
        else if elementName == "description" {
            self.desc = foundCharacters
        }

            // if we reached the </marker> tag, we do not
            // have anything further to do, so delegate
            // parsing responsibility to parent
        else if elementName == "item" {
            parser.delegate = self.parent
        }

        // reset found characters
        foundCharacters = ""
    }

}
