//
//  ParserBase.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation

class ParserBase : NSObject, XMLParserDelegate  {

    var currentElement:String = ""
    var foundCharacters = ""
    weak var parent:ParserBase? = nil

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {

        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundCharacters += string
    }

}
