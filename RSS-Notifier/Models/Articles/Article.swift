//
//  Article.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2022-01-02.
//

import Foundation


public struct Article {
    var title = ""
    var date = Date()
    var link = ""
    var category = ""
    var desc = ""
    var timeSincePubInMin = 0
    var time = ""
    var source = ""
    var isClicked = false


    /// Creates and assignes the attributes from an news item to a article
    ///
    ///  - Parameters:
    ///     item - An article from the RSS
    ///     outline - The news source from the XML subscriptions
    ///     time - The time in minutes since article was published
    ///
    ///  - Returns: An article containing info from the RSS source
    ///
    func createArticle(_ item: RSSItem, _ outline: Outline, _ time: Int) -> Article {
        var article = Article()
        article.title = item.title ?? ""
        article.link = item.link ?? ""
        article.date = item.pubDate ?? Date.now
        article.time = calculateTime(minutesSincePub: time)
        article.category = outline.category
        article.source = outline.title
        article.desc = item.description

        return article
    }


    /*
     Calculates the time and puts it into a string to be used next to the title
     Formats the time to ex, 1h 24 min instead of 84 min
     */
    func calculateTime(minutesSincePub: Int) -> String {
        var time = String(minutesSincePub) + "m"
        if (minutesSincePub > 60) {
            let hours = minutesSincePub / 60
            let minutes = minutesSincePub % 60
            time = String(hours) + "h " + String(minutes) + "m"
        }

        return time
    }
}

