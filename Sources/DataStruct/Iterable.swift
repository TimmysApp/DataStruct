//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/17/22.
//

import Foundation

public protocol Iterable {
    static var dataKeys: [String: String] {get}
    static var nonDataKeys: [String] {get}
    func allProperties() -> [String: Any]?
}

public extension Iterable {
    static var nonDataKeys: [String] {
        return []
    }
    static var dataKeys: [String: String] {
        return [:]
    }
    func allProperties() -> [String: Any]? {
        var result: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return nil
        }
        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }
            result[property] = value
        }
        return result
    }
}
