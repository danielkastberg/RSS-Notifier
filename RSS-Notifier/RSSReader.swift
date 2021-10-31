//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//

import Foundation

class RSSReader: ParserBase {
    var url: URL?
    override init() {
        self.url = URL(string: "https://m.sweclockers.com/feeds/forum/trad/999559")!
    }
    
    func startRss() {
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            let parser = XMLParser(data: data)

            let channel = ChannelParser()
            parser.delegate = channel

            parser.parse()
            
            print("coord has a count attribute of \(channel.count)")
            print("coord has \(channel.items.count) items")

            for item in channel.items {
                print("item = \(item.title) \(item.link) \(item.desc)")
            }
        }
        task.resume()
    }
}


