////
////  ItemParser.swift
////  RSS-Notifier
////
////  Created by Daniel Kastberg on 2021-10-31.
////
//
//import Foundation
//
//
//
//class Outline : ParserBase {
//
//    var html:String = ""
//    var xmlUrl:String = ""
//    var title:String = ""
//    var icon = ""
//
//
//    override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
//
//        if elementName == "outline" {
//
//
//            if attributeDict["title"] == nil {
//                self.foundTitle = ""
//            }
//            else if attributeDict["htmlUrl"] == nil {
//                self.foundHtml = ""
//                self.icon = foundHtml+"/favicon.ico"
//            }
//            else if attributeDict["xmlUrl"] == nil {
//                foundXmlUrl = ""
//            }
//            else {
//                self.foundTitle = attributeDict["title"]! as String
//                self.foundHtml = attributeDict["htmlUrl"]! as String
//                self.foundXmlUrl = attributeDict["xmlUrl"]! as String
//            }
//        }
//
//
//        currentElement = elementName
//    }
//}
