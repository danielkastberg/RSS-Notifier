//
//  HelperFunc.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2023-01-01.
//

import Foundation


struct HelperFunc {

    static let shared = HelperFunc()

    /// Removes duplicate items from a set
    ///  - Parameters:
    ///     source - The set containing duplicates
    func uniqueSet<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }

    
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
