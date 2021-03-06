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
    var listOfOutlines = [Outline]()
    var listOfCategories = [Category]()
    var categoryName = ""
    


    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "category" {
            categoryName = attributeDict["title"]! as String
        }
        
        if elementName == "outline" {
            let outline = Outline()
            outline.category = categoryName
            
            if attributeDict["title"] == nil {
                outline.title = ""
            }
            else {
                outline.title = attributeDict["title"]!
            }
            
            if attributeDict["htmlUrl"] == nil {
                outline.html = ""
            }
            else {
                outline.html = attributeDict["htmlUrl"]! as String
            }
            
            if attributeDict["xmlUrl"] == nil {
                outline.rss = ""
            }
            else {
                outline.rss = attributeDict["xmlUrl"]! as String
                if outline.html.last == "/" {
                    outline.icon = outline.html+"favicon.ico"
                }
                else {
                    outline.icon = outline.html+"/favicon.ico"
                }
                
            }
  
            listOfOutlines.append(outline)
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
        if elementName == "category" {
//            var category = Category()
//            categoryName = elementName
//            category.title = categoryName
//            category.outlines = listOfOutlines
//            listOfCategories.append(category)
//            listOfCategories[count].outlines = listOfOutlines
//            count += 1
//            listOfOutlines = [Outline]()
            
        }
        
    }
    
    func getOutlines() -> [Outline] {
        return listOfOutlines
    }
    
    func getCategories() -> [Category] {
        return listOfCategories
    }

}
