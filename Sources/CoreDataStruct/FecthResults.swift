//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/20/22.
//

import Foundation
import Combine

@available(iOS 14.0, macOS 11.0, *)
public struct SectionedFecthResults<Value: Datable> {
//MARK: - Internal Properties
    internal var isPaused = PassthroughSubject<Bool, Never>()
//MARK: - Public Properties
    public var sections = [[Value]]()
//MARK: - Public Functions
    public func resume() {
        isPaused.send(true)
    }
    public func cancel() {
        isPaused.send(false)
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct ModelFecthResults<Value: Datable> {
//MARK: - Internal Properties
    internal var isPaused = PassthroughSubject<Bool, Never>()
//MARK: - Public Properties
    public var models = [Value]()
//MARK: - Public Functions
    public func resume() {
        isPaused.send(true)
    }
    public func cancel() {
        isPaused.send(false)
    }
}
