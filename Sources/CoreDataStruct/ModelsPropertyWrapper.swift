//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/9/22.
//

import Foundation
import SwiftUI
import Combine

@propertyWrapper public struct FetchedModels<Value: Datable>: DynamicProperty {
    private var defaultValue: [Value]
    private let publisher = Value.modelData
    private let predicate: NSPredicate?
    private let sortDescriptors: [NSSortDescriptor]?
    public init(defaultValue: [Value] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        self.defaultValue = []
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
    }
    public var wrappedValue: [Value] {
        get {
            defaultValue
        }
        nonmutating set {
        }
    }
    public var projectedValue: AnyPublisher<[Value], Never> {
        publisher
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
    }
}


@propertyWrapper public struct SectionedModels<Value: Datable>: DynamicProperty {
    private var defaultValue: [[Value]]
    private let publisher = Value.modelData
    private let predicate: NSPredicate?
    private let sortDescriptors: [NSSortDescriptor]?
    private let condition: (([Value], Value) -> Bool)
    public init(wrappedValue value: [[Value]] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, sections: @escaping ([Value], Value) -> Bool) {
        self.defaultValue = value
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.condition = sections
    }
    public var wrappedValue: [[Value]] {
        get {
            defaultValue
        }
        nonmutating set {
        }
    }
    public var projectedValue: AnyPublisher<[[Value]], Never> {
        publisher
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .map { datable in
                return datable.reduce(into: [[Value]]()) { partialResult, element in
                    if let index = partialResult.firstIndex(where: {condition($0, element)}) {
                        partialResult[index].append(element)
                    }else {
                        partialResult.append([element])
                    }
                }
            }.eraseToAnyPublisher()
    }
}
