//
//  ParserBase.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

struct Outline {
    var title = ""
    var html = ""
}

import Foundation

class ParserBase : NSObject, XMLParserDelegate  {

    var currentElement:String = ""
    var foundCharacters = ""
    var foundHtml = ""
    var foundTitle = ""
    weak var parent:ParserBase? = nil
    
    var depth = 0
    var depthIndent: String {
        return [String](repeating: "  ", count: self.depth).joined()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        foundTitle = attributeDict["title"]! as String
        foundHtml = attributeDict["htmlUrl"]! as String
        
        
//        guard let html = attributeDict["htmlUrl"] else {
//
//            return
//        }
//
        
//        foundHtml = html
    
       
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundCharacters += string
    }
    
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            print("CDATA contains non-textual data, ignored")
            return
        }
        self.foundCharacters += string
    }

}
