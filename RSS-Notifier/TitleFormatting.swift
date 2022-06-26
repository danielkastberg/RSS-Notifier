//
//  TitleFormatting.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-12-27.
//

import Foundation

/*
 If the title of the article is to long the functions cut it of after 40 char
 and adds thre dots ... to indicate that the full title isn't showing
 */
func shortenText(item: String) -> String {
    var title = ""
    let stringLength = 40
   
    if item.count > stringLength {
        title = item
        for _ in stringLength...title.count {
            title.remove(at: title.index(before: title.endIndex))
        }
        title.append("...")
    }
    else {
        title = item
    }
    return title
}
