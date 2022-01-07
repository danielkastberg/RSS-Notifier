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

private var latestArticle = ""

/// Checks authorization and if allowed shows the user a notification.
///  - Parameters:
///     article - The article to display
func notifyUser(article: Article) {
    un.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
//        if authorized {
//            print("Authorized")
//        }
//        else if !authorized {
//            print("Not authorized")
//
//        }
//        else {
//            print(error?.localizedDescription as Any)
//        }
        
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                
                let content = UNMutableNotificationContent()
                
                content.title = article.category
                content.subtitle = article.source
                content.body = article.title
                content.threadIdentifier = "RSS Notifier"
                content.categoryIdentifier = "News"

                
                content.sound = nil
                

                let imageURL = loadImageURL(article.source)
                
                
                do {
                    let attachment = try UNNotificationAttachment.init(identifier: article.source, url: imageURL, options: .none)
                    content.attachments = [attachment]
                } catch {
                    print("Error loading image : \(error)")
                }
                
                let open = UNNotificationAction(identifier: "Open", title: "Open", options: [.destructive])

         
                let category = UNNotificationCategory(identifier: content.categoryIdentifier, actions: [open], intentIdentifiers: [], options: [])
                
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let id = article.category
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
    
                un.setNotificationCategories([category])
                

                un.add(request) { (error) in
                    if error != nil {print(error?.localizedDescription as Any)}
                }
            }
        }
    }
}


/// Checks authorization and if allowed shows the user a notification saying the program couldn't load the RSS
func notfiyOffline() {
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
                
                content.title = "Could not load news"
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

// copy sound file to /Library/Sounds directory, it will be auto detect and played when a push notification arrive
func copyFileToDirectory(fromPath:String, fileName:String) {
    do {
        let libraryDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let directoryPath = "\(libraryDir.first!)/Sounds"
        try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)

        let systemSoundPath = "\(fromPath)/\(fileName)"
        let notificationSoundPath = "\(directoryPath)/paper-effect.caf"

        let fileExist = FileManager.default.fileExists(atPath: notificationSoundPath)
        if (fileExist) {
            try FileManager.default.removeItem(atPath: notificationSoundPath)
        }
        try FileManager.default.copyItem(atPath: systemSoundPath, toPath: notificationSoundPath)
    }
    catch let error as NSError {
        print("Error: \(error)")
    }
}

