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
    var count = 0
    var listOFOutlines = [Outline]()
    


    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "outline" {
            var outline = Outline()
            
            if attributeDict["title"] == nil {
                outline.title = ""
            }
            else {
                outline.title = attributeDict["title"]!
            }
            
            if attributeDict["htmlUrl"] == nil {
                outline.html = ""
//                print(outline.title)
            }
            else {
                outline.html = attributeDict["htmlUrl"]! as String
            }
            
            if attributeDict["xmlUrl"] == nil {
                outline.xmlUrl = ""
            }
            else {
                outline.xmlUrl = attributeDict["xmlUrl"]! as String
                outline.icon = outline.html+"/favicon.ico"
            }
  
            listOFOutlines.append(outline)
        }
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
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "outline" {
            count += 1
        }
    }
    
    func getOutlines() -> [Outline] {
        return listOFOutlines
    }

}
