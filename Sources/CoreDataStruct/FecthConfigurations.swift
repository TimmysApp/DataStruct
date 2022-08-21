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
public class FecthConfigurations<Value: Datable>: ObservableObject {
//MARK: - Public Properties
    @Published public var models = [Value]()
    @Published public var sections = [[Value]]()
    @Published public var isEmpty = false
//MARK: - Private Properties
    private let isSectioned: Bool
    private let predicate: NSPredicate?
    private let sortDescriptors: [NSSortDescriptor]?
    private let sectionsRules: (([Value], Value) -> Bool)?
    private var cancellable: AnyCancellable?
//MARK: - Internal Initializer
    internal init(value: [Value], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) {
        self.isSectioned = false
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionsRules = nil
        self.models = value
        resume()
    }
    internal init(value: [[Value]], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = [], sectionsRules: @escaping ([Value], Value) -> Bool) {
        self.isSectioned = true
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionsRules = sectionsRules
        self.sections = value
        resume()
    }
}

//MARK: - Public Functions
@available(iOS 14.0, macOS 11.0, *)
internal extension FecthConfigurations {
    func resume() {
        guard cancellable == nil else {return}
        if isSectioned {
            resumeSectioned()
        }else {
            resumeModel()
        }
    }
    func cancel() {
        cancellable = nil
    }
}

//MARK: - Private Functions
@available(iOS 14.0, macOS 11.0, *)
private extension FecthConfigurations {
    func resumeSectioned() {
        cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .receive(on: RunLoop.main)
            .map { [weak self] datable in
                guard let strongSelf = self, let sectionsRules = strongSelf.sectionsRules else {
                    fatalError("Something went wrong")
                }
                return datable.reduce(into: [[Value]]()) { partialResult, element in
                    if let index = partialResult.firstIndex(where: {sectionsRules($0, element)}) {
                        partialResult[index].append(element)
                    }else {
                        partialResult.append([element])
                    }
                }
            }.sink { [weak self] value in
                self?.isEmpty = value.isEmpty
                self?.sections = value
            }
    }
    func resumeModel() {
        cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isEmpty = value.isEmpty
                self?.models = value
            }
    }
}
