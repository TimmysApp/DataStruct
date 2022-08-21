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
@MainActor internal final class FecthConfigurations<Value: Datable>: ObservableObject {
    //MARK: - Public Properties
    @Published public var modelResults: ModelFecthResults<Value>?
    @Published public var sectionResults: SectionedFecthResults<Value>?
    //MARK: - Private Properties
    @Published private var isPaused = false {
        didSet {
            togglePause()
        }
    }
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
        self.modelResults = ModelFecthResults(models: value)
        self.modelResults?.isPaused
            .assign(to: &$isPaused)
        togglePause()
    }
    internal init(value: [[Value]], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = [], sectionsRules: @escaping ([Value], Value) -> Bool) {
        self.isSectioned = true
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionsRules = sectionsRules
        self.sectionResults = SectionedFecthResults(sections: value)
        self.sectionResults?.isPaused
            .assign(to: &$isPaused)
        togglePause()
    }
}

//MARK: - Private Functions
@available(iOS 14.0, macOS 11.0, *)
private extension FecthConfigurations {
    func resumeSectioned() {
       cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
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
                self?.sectionResults?.sections = value
            }
    }
    func resumeModel() {
        cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .sink { [weak self] value in
                self?.modelResults?.models = value
            }
    }
    func togglePause() {
        if isPaused {
            cancellable = nil
        }else {
            guard cancellable == nil else {return}
            if isSectioned {
                resumeSectioned()
            }else {
                resumeModel()
            }
        }
    }
}
