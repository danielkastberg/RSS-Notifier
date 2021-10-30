//
//  RSSReader.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-30.
//

import Foundation


let url = URL(string: "https://m.sweclockers.com/feeds/forum/trad/999559")!



func searchRss(_url:String) {
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!)
    }

    task.resume()
}
