//
//  Notifications.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-12-27.
//

import Foundation
import UserNotifications
import AppKit


let un = UNUserNotificationCenter.current()


func notifyUser(article: Article, icons: [String: NSImage]) {
//    print("\(categoryTitle) + \(articleTitle) + \(source)")
    un.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
        if authorized {
            print("Authorized")
        }
        else if !authorized {
            print("Not authorized")
            
        }
        else {
            print(error?.localizedDescription as Any)
        }
        
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                
                let content = UNMutableNotificationContent()
                
                content.title = article.category
                content.subtitle = article.source
                content.body = article.title
                content.threadIdentifier = "RSS Notifier"
                content.sound = UNNotificationSound.default
                
         
                
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let id = article.source
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                un.add(request) { (error) in
                    if error != nil {print(error?.localizedDescription as Any)}
                }
            }
        }
    }
}


func notfiyOffline() {
//    print("\(categoryTitle) + \(articleTitle) + \(source)")
    un.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
        if authorized {
            print("Authorized")
        }
        else if !authorized {
            print("Not authorized")
            
        }
        else {
            print(error?.localizedDescription as Any)
        }
        
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                
                let content = UNMutableNotificationContent()
                
                content.title = "No internet connection"
                content.threadIdentifier = "RSS Notifier"
                content.sound = UNNotificationSound.default
                
         
                
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let id = "No internet"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                un.add(request) { (error) in
                    if error != nil {print(error?.localizedDescription as Any)}
                }
            }
        }
    }
}
