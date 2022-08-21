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
    public var wrappedValue: ModelFecthResults<Value> {
        get {
            modelData.modelResults!
        }
        nonmutating set {
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@propertyWrapper public struct SectionedModels<Value: Datable>: DynamicProperty {
    @State public var sectionResults = SectionedFecthResults<Value>()
    private let predicate: NSPredicate?
    private let sortDescriptors: [NSSortDescriptor]?
    private let sectionsRules: (([Value], Value) -> Bool)?
    @State private var cancellable: AnyCancellable?
    public init(defaultValue: [[Value]] = [], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, sections: @escaping ([Value], Value) -> Bool) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionsRules = sections
        self.sectionResults = SectionedFecthResults(sections: defaultValue)
        resumeSectioned()
    }
    public var wrappedValue: SectionedFecthResults<Value> {
        get {
            sectionResults
        }
        nonmutating set {
        }
    }
    func resumeSectioned() {
       cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .map { datable in
                guard let sectionsRules = sectionsRules else {
                    fatalError("Something went wrong")
                }
                return datable.reduce(into: [[Value]]()) { partialResult, element in
                    if let index = partialResult.firstIndex(where: {sectionsRules($0, element)}) {
                        partialResult[index].append(element)
                    }else {
                        partialResult.append([element])
                    }
                }
            }.sink { value in
                self.sectionResults.sections = value
            }
    }
}
