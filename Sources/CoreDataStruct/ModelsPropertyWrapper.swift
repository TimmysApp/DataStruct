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
    @StateObject private var modelData: ModelConfigurations<Value>
    public init(defaultValue: [Value] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        self._modelData = StateObject(wrappedValue: ModelConfigurations(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors))
    }
    public var wrappedValue: StateObject<ModelConfigurations<Value>> {
        get {
            _modelData
        }
        nonmutating set {
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@propertyWrapper public struct SectionedModels<Value: Datable>: DynamicProperty {
    @StateObject private var modelData: SectionConfigurations<Value>
    public init(defaultValue: [[Value]] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, sections: @escaping ([Value], Value) -> Bool) {
        self._modelData = StateObject(wrappedValue: SectionConfigurations(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors, sectionsRules: sections))
    }
    public var wrappedValue: StateObject<SectionConfigurations<Value>> {
        get {
            _modelData
        }
        nonmutating set {
        }
    }
}
