//
//  File.swift
//  
//
//  Created by Joe Maghzal on 8/20/22.
//

import Foundation
import Combine
import CoreData

@available(iOS 14.0, macOS 11.0, *)
@MainActor public class SectionConfigurations<Value: Datable>: ObservableObject {
//MARK: - Public Properties
    @Published public var sections = [[Value]]()
//MARK: - Private Properties
    private let predicate: NSPredicate?
    private let sortDescriptors: [NSSortDescriptor]?
    private let sectionsRules: ([Value], Value) -> Bool
    private var cancellable: AnyCancellable?
//MARK: - Internal Initializer
    init(value: [[Value]], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = [], sectionsRules: @escaping ([Value], Value) -> Bool) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionsRules = sectionsRules
        self.sections = value
        resume()
    }
}

//MARK: - Public Functions
@available(iOS 14.0, macOS 11.0, *)
public extension SectionConfigurations {
    func resume() {
        guard cancellable == nil else {return}
        cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .receive(on: RunLoop.main)
            .map { [weak self] datable in
                guard let strongSelf = self else {
                    fatalError("Something went wrong")
                }
                return datable.reduce(into: [[Value]]()) { partialResult, element in
                    if let index = partialResult.firstIndex(where: {strongSelf.sectionsRules($0, element)}) {
                        partialResult[index].append(element)
                    }else {
                        partialResult.append([element])
                    }
                }
            }.sink { [weak self] value in
                self?.sections = value
            }
    }
    func cancel() {
        cancellable = nil
    }
}
