//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/9/22.
//

import Foundation
import SwiftUI
import Combine

@available(macOS 11.0, *)
@propertyWrapper public struct FetchedModels<Value: Datable>: DynamicProperty {
    @StateObject var modelData: DatableFecthedValues<Value>
    public init(defaultValue: [Value] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        self._modelData = StateObject(wrappedValue: DatableFecthedValues(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors))
    }
    public var wrappedValue: [Value] {
        get {
            modelData.models
        }
        nonmutating set {
        }
    }
}

@available(macOS 11.0, *)
@propertyWrapper public struct SectionedModels<Value: Datable>: DynamicProperty {
    @StateObject var modelData: DatableFecthedValues<Value>
    public init(defaultValue: [[Value]] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, sections: @escaping ([Value], Value) -> Bool) {
        self._modelData = StateObject(wrappedValue: DatableFecthedValues(value: defaultValue, predicate: predicate, sortDescriptors: sortDescriptors, sections: sections))
    }
    public var wrappedValue: [[Value]] {
        get {
            modelData.sections
        }
        nonmutating set {
        }
    }
}

@available(macOS 11.0, *)
@MainActor class DatableFecthedValues<Value: Datable>: ObservableObject {
    @Published var sections = [[Value]]()
    @Published var models = [Value]()
    public init(value: [[Value]], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = [], sections: @escaping ([Value], Value) -> Bool) {
        self.sections = value
        Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .receive(on: RunLoop.main)
            .map { datable in
                return datable.reduce(into: [[Value]]()) { partialResult, element in
                    if let index = partialResult.firstIndex(where: {sections($0, element)}) {
                        partialResult[index].append(element)
                    }else {
                        partialResult.append([element])
                    }
                }
            }.assign(to: &$sections)
    }
    public init(value: [Value], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) {
        self.models = value
        Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .receive(on: RunLoop.main)
            .assign(to: &$models)
    }
}
