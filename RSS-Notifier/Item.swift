//
//  ItemParser.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation



class Item : ParserBase {
    
    var html:String = ""
    var xmlUrl:String = ""
    var title:String = ""
    var date: Date = Date()
    var outline = [Outline]()
    var out = Outline()
    

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        

        // if we finished an item tag, the ParserBase parent
        // would have accumulated the found characters
        // so just assign that to our item variable
        if elementName == "outline" {
            out.xmlUrl = foundXmlUrl
            out.html = foundHtml
            out.title = foundTitle
            html = foundHtml
            xmlUrl = foundXmlUrl
            title = foundTitle
            outline.append(out)
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
    
    func getOutline() -> Outline {
        print("fuck you")
        print(out.html)
        return out
    }

}
