//
//  ItemParser.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation


class ItemParser : ParserBase {

    var item = Item()

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        print("processing <\(elementName)> tag from Item")

        // if we finished an item tag, the ParserBase parent
        // would have accumulated the found characters
        // so just assign that to our item variable
        if elementName == "title" {
            item.title = foundCharacters
        }
        else if elementName == "link" {
            item.link = foundCharacters
        }
        else if elementName == "description" {
            item.desc = foundCharacters
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
