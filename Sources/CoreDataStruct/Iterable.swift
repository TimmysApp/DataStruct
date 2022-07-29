//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/17/22.
//

import Foundation

public protocol Iterable {
    func allProperties() throws -> [String: Any]
}

public extension Iterable {
    func allProperties() throws -> [String: Any] {
        var result: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
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
