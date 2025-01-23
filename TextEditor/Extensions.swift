//
//  Extensions.swift
//  Pg2
//
//  Created by Mert Arıcan on 20.08.2023.
//

import Foundation

extension Dictionary {
    var description: String {
        self.keys.map { key in
            "key: \(key) --> value: \(self[key]!)"
        }.joined(separator: "\n")
    }
}

extension Array where Element: Equatable {
    mutating func insertUnique(_ element: Element, at index: Int) {
        if !self.contains(element) {
            self.insert(element, at: index)
        }
    }
}

extension Dictionary {
    mutating func add<T>(_ element: T, forKey key: Key) where Value == [T] {
           self[key] == nil ? self[key] = [element] : self[key]?.append(element)
       }
    
    mutating func insertUnique<T>(_ element: T, forKey key: Key, at index: Int) where Value == [T], T: Equatable {
        self[key] == nil ? self[key] = [element] : self[key]?.insertUnique(element, at: index)
    }
}
