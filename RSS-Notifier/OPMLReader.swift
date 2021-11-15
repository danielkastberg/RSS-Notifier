//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation



class OPMLReader: ParserBase {
    
    func readOPML() {
        
        let xmlPath = Bundle.main.path(forResource: "Subscriptions", ofType: "xml")
        let url1 = URL(fileURLWithPath: xmlPath!) 
        do {
            var data = try Data(contentsOf: url1)
            let parser = XMLParser(data: data)
            let category = Category()
     
            parser.delegate = category
            

            parser.parse()
            print(category.numberOfCategories)

//            for item in channel.items {
////                print("item = \(item.title) \(item.link) \(item.desc)")
//                print("\(item.title)")
//            }
        }
        catch {
            print("error dude")
        }
        



    }
}

