//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-31.
//
//Ladda ner verktyg för HTTP läsning, RSS läsning 
import Foundation

class RSSReader: ParserBase {
    var url: URL = URL(string: "https://m.sweclockers.com/feeds/forum/trad/999559")!
    var count: Int = 0
    var channels: Array<Channel> = []
    var items: Array<Item> = []
    func startRss(completionBlock: @escaping (Array<Item>) -> Void) -> Void {
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) {
                (data: Data?, response: URLResponse?, error: Error?) in
            
            if(error != nil) {
                print("Error: \(String(describing: error))")
            }else
            {
                let parser = XMLParser(data: data!)

                let channel = Channel()
                parser.delegate = channel

                parser.parse()
                
                print("coord has a count attribute of \(channel.count)")
                print("coord has \(channel.items.count) items")
                
                

                for item in channel.items {
                    self.count+=1
                    self.items.append(item)
            
                }
                //let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                //send this block to required place
                completionBlock(self.items);
            }
        }
        task.resume()
            }

      
        }


