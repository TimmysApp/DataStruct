//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/9/22.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, macOS 11.0, *)
@propertyWrapper public struct FetchedModels<Value: Datable>: DynamicProperty {
    @StateObject private var modelData: FecthConfigurations<Value>
    public init(defaultValue: [Value] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        self._modelData = StateObject(wrappedValue: FecthConfigurations(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors))
    }
    public var wrappedValue: FecthConfigurations<Value> {
        get {
            modelData
        }
        nonmutating set {
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@propertyWrapper public struct SectionedModels<Value: Datable>: DynamicProperty {
    @StateObject private var modelData: FecthConfigurations<Value>
    public init(defaultValue: [[Value]] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, sections: @escaping ([Value], Value) -> Bool) {
        let configs =  FecthConfigurations(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors, sectionsRules: sections)
        self._modelData = StateObject(wrappedValue: configs)
    }
    public var wrappedValue: SectionedFecthResults<Value> {
        get {
            modelData.sections
        }
        nonmutating set {
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct SectionedFecthResults<Value: Datable> {
    internal var isPaused = PassthroughSubject<Bool, Never>()
    public var sections = [[Value]]()
    public func resume() {
        isPaused.send(true)
    }
    public func cancel() {
        isPaused.send(false)
    }
}
