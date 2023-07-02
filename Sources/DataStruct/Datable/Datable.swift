//
//  File.swift
//  
//
//  Created by Joe Maghzal on 5/7/22.
//

import Foundation
import CoreData

public protocol Datable: Identifiable, Iterable {
    associatedtype Object: NSManagedObject
    var oid: UUID? {get set}
    var id: UUID? {get set}
    static var dataKeys: [String: String] {get}
    static var nonDataKeys: [String] {get}
//MARK: - Mapping
    static func map(from object: Object?) -> Self?
    func map(object: Object, isUpdating: Bool) -> Object
//MARK: - Fetching
    static var modelData: ModelData<Self> {get}
}

public extension Datable {
    static var nonDataKeys: [String] {
        return []
    }
    static var dataKeys: [String: String] {
        return [:]
    }
//MARK: - Mapping
    var oid: UUID? {
        get {
            return id
        }
        set {
            id = newValue
        }
    }
//MARK: - Entity
    var savedObject: Object? {
        guard let oid else {
            return nil
        }
        return try? Self.fetching(with: NSPredicate(format: "oid = %@", "\(oid)")).first
    }
    var object: Object {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        return map(object: Object(context: viewContext), isUpdating: false)
    }
//MARK: - Writing
    func save(_ forceCreate: Bool = false) {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        viewContext.perform {
            do {
                if let savedObject, !forceCreate {
                    _ = map(object: savedObject, isUpdating: true)
                    try viewContext.save()
                }else {
                    _ = object
                    try viewContext.save()
                }
            }catch {
                print(error)
            }
        }
    }
    func delete() {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        do {
            guard let savedObject else {return}
            viewContext.delete(savedObject)
            try viewContext.save()
        }catch {
            print(error)
        }
    }
//MARK: - Fetching
    static func fetch(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) throws -> [Self] {
        return try fetching(with: predicate, sortDescriptors: sortDescriptors).model()
    }
    static func fetching(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) throws -> [Self.Object] {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        guard let fetchRequest = Object.fetchRequest() as? NSFetchRequest<Object> else {
            throw CoreDataStructError.invalidRequest
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        let objects = try viewContext.fetch(fetchRequest)
        return objects
    }
}

public extension Array {
    func model<T: Datable>() -> [T] {
        return compactMap({T.map(from: $0 as? T.Object)})
    }
}

public extension NSSet {
    func model<T: Datable>() -> [T] {
        return allObjects.compactMap({T.map(from: $0 as? T.Object)})
    }
}

enum CoreDataStructError: Error {
    case invalidRequest
}
