//
//  FontHandler.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2022-03-11.
//

import Foundation
import Cocoa

private let fontsize: CGFloat = 12

/// Loads a custom font from the info.plist
func useCustomFont(title: String) -> NSMutableAttributedString {
    let font = NSFont(name: "OpenSans-Regular", size: fontsize)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.firstLineHeadIndent = 5.0
    
    return NSMutableAttributedString(string: title, attributes: [.font : font])
}


