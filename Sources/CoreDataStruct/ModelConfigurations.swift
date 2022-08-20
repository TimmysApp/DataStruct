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
@MainActor public class ModelConfigurations<Value: Datable>: ObservableObject {
//MARK: - Public Properties
    @Published public var models = [Value]()
//MARK: - Private Properties
    private let predicate: NSPredicate?
    private let sortDescriptors: [NSSortDescriptor]?
    private var cancellable: AnyCancellable?
//MARK: - Internal Initializer
    init(value: [Value], predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.models = value
        resume()
    }
}
//MARK: - Public Functions
@available(iOS 14.0, macOS 11.0, *)
public extension ModelConfigurations {
    func resume() {
        guard cancellable == nil else {return}
        cancellable = Value.modelData
            .with(predicate: predicate, sortDescriptors: sortDescriptors)
            .publisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.models = value
            }
    }
    func cancel() {
        cancellable = nil
    }
}
