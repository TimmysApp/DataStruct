//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/17/22.
//

import Foundation
import CoreData

public protocol Rawable {
    var raw: Any? {get}
    var rawKeys: [RawKey] {get}
    var rawValues: [RawData] {get}
}

public extension Rawable {
    var raw: Any? {
        return nil
    }
    var rawKeys: [RawKey] {
        return []
    }
    var rawValues: [RawData] {
        return []
    }
}

public struct RawKey {
    public var originalKey: String
    public var rawKey: String
}

public struct RawData {
    public var key: String
    public var raw: Any
}
