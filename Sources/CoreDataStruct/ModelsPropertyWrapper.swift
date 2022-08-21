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
        self._modelData = StateObject(wrappedValue: FecthConfigurations(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors, sectionsRules: sections))
    }
    public var wrappedValue: SectionedFecthResults<Value> {
        get {
            SectionedFecthResults(configurations: modelData)
        }
        nonmutating set {
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct SectionedFecthResults<Value: Datable> {
    private var configurations: FecthConfigurations<Value>
    public var isEmpty: Bool {
        get {
            configurations.isEmpty
        }
    }
    public var sections: [[Value]] {
        get {
            configurations.sections
        }
    }
    public func resume() {
        configurations.resume()
    }
    public func cancel() {
        configurations.cancel()
    }
    internal init(configurations: FecthConfigurations<Value>) {
        self.configurations = configurations
    }
}

