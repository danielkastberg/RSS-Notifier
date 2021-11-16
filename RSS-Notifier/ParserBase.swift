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
    var foundHtml = ""
    var foundXmlUrl = ""
    var foundTitle = ""
    weak var parent:ParserBase? = nil
    


    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.foundTitle = attributeDict["title"]! as String
        self.foundHtml = attributeDict["htmlUrl"]! as String
        self.foundXmlUrl = attributeDict["xmlUrl"]! as String
        
        
        
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
