//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/29/22.
//

import Foundation
import CoreData
import Combine

public final class DataConfigurations: ObservableObject {
    static var shared = DataConfigurations()
    var managedObjectContext: NSManagedObjectContext?
    var errorsPublisher = PassthroughSubject<Error, Never>()
//MARK: - Functions
    public static func setObjectContext(_ managedObjectContext: NSManagedObjectContext) {
        DataConfigurations.shared.managedObjectContext = managedObjectContext
    }
    public static func errors() -> AnyPublisher<Error, Never> {
        return DataConfigurations.shared.errorsPublisher.eraseToAnyPublisher()
    }
}
