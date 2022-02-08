//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation

let subscriptions = "Subscriptions"
let type = "xml"

//public struct Outline {
//    var title = ""
//    var html = ""
//    var xmlUrl = ""
//    var icon = ""
//    var category = ""
//}

@objcMembers public class Outline: NSObject {
    var title = ""
    var html = ""
    var xmlUrl = ""
    var icon = ""
    var category = ""
}


public struct Category {
    var title = ""
    var outlines = [Outline]()
  
}




class OPMLReader {
    private let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var listOfCategories = [Category]()
    func readOPML() -> [Outline]  {
        var outlines = [Outline]()
        
        let xmlPath = Bundle.main.path(forResource: subscriptions, ofType: type)
        if xmlPath == nil {
            NSLog("Failed to find Subscription file")
        }
        let url = URL(fileURLWithPath: xmlPath!)
        do {
            let data = try Data(contentsOf: url)
            let parser = XMLParser(data: data)
            let parserBase = ParserBase()
            parser.delegate = parserBase

            parser.parse()
            outlines = parserBase.getOutlines()
            listOfCategories = parserBase.getCategories()
            

//            for item in category.items {
//                print("item = \(item.title) \(item.xmlUrl) \(item.html)")
//            }
        }
        catch {
            NSLog("Failed to parse opml file")
        }
        return outlines
    }
    
    
    func writeOPML(_ outlines: [Outline]) {
//        let xmlPath = Bundle.main.path(forResource: subscriptions, ofType: type)
//        var url = URL(fileURLWithPath: xmlPath!)
//    do {
//        let xml = try XMLDocument.init(contentsOf: url, options: .documentIncludeContentTypeDeclaration)
//
//        print(xml.child(at: 0))
//    }
//    catch {
//        print("hel")
//    }
        let root = XMLElement(name: "opml")
        let unicode = XMLNode.attribute(withName: "version", stringValue: "1.0") as! XMLNode
        root.addAttribute(unicode)
        let xml = XMLDocument(rootElement: root)
        xml.characterEncoding = "utf-8"
        let body = XMLElement(name: "body")
        root.addChild(XMLElement(name: "head", stringValue:"RSS Notifier Subscriptions"))
        root.addChild(body)

        for category in listOfCategories {
            let cat = XMLNode.attribute(withName: "title", stringValue: category.title) as! XMLNode
            let catElm = XMLElement(name: "category")
            print(catElm)
            catElm.addAttribute(cat)
            body.addChild(catElm)
            
            for outline in outlines {
                // Categorize and create outlines
                if outline.category == category.title {
                    let outElm = outlineElm(outline)
                    catElm.addChild(outElm)
                }
            }
            
            // Remove a category element if it is empty
            if catElm.childCount == 0 && cat.stringValue! == listOfCategories[catElm.index].title {
                listOfCategories.remove(at: catElm.index)
                body.removeChild(at: catElm.index)
            }
        }
     
        // Convert to Data
        let opt = XMLNode.Options.nodePrettyPrint
        let data = xml.xmlData(options: opt)
        print(xml.xmlString(options: opt))
        let filePath = directory.appendingPathComponent("Subb"+".xml")
        
        do {
            try data.write(to: filePath)
            
        }
        catch let error as NSError {
            print("Error writing values \(error)")
        }
    }
    

    /// Creates an XMLElement with all the attributes for an outline
    ///  - Parameters:
    ///     outline - The outline with attributes
    ///
    ///   - Returns:XMLElement
    private func outlineElm(_ outline: Outline) -> XMLElement {
        let outElm = XMLElement(name: "outline")
        let title = XMLNode.attribute(withName: "title", stringValue: outline.title) as! XMLNode
        let htmlUrl = XMLNode.attribute(withName: "htmlUrl", stringValue: outline.html) as! XMLNode
        let xmlUrl = XMLNode.attribute(withName: "xmlUrl", stringValue: outline.xmlUrl) as! XMLNode
        outElm.addAttribute(title)
        outElm.addAttribute(htmlUrl)
        outElm.addAttribute(xmlUrl)
        return outElm
    }
    
    
    //    private func convertOutline(outlines: [Outline]) -> [OutlineClass] {
    //        for outline in outlines {
    //            let outC = OutlineClass()
    //            outC.title = outline.title
    //            outC.xmlUrl = outline.xmlUrl
    //            outC.category = outline.category
    //            self.outlineClass.append(outC)
    //        }
    //    }
}



