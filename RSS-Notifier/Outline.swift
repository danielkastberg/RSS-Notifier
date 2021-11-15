//
//  ItemParser.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation



class Outline : ParserBase {
    
    var html:String = ""
    var xmlUrl:String = ""
    var title:String = ""
    var date: Date = Date()
    

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        

        // if we finished an item tag, the ParserBase parent
        // would have accumulated the found characters
        // so just assign that to our item variable
        if elementName == "outline" {
            html = foundHtml
            xmlUrl = foundXmlUrl
            title = foundTitle
            self.title = foundCharacters
        }

            // if we reached the </marker> tag, we do not
            // have anything further to do, so delegate
            // parsing responsibility to parent
        else if elementName == "category" {
            parser.delegate = self.parent
        }

        // reset found characters
        foundCharacters = ""
    }
}
