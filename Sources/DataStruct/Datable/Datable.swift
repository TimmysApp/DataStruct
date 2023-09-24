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
    associatedtype ObjectID: Hashable
    var oid: ObjectID? {get set}
    var id: ObjectID? {get set}
    static var dataKeys: [String: String] {get}
    static var nonDataKeys: [String] {get}
//MARK: - Mapping
    static func map(from object: Object?) -> Self?
    func map(object: Object, isUpdating: Bool, objectContext: NSManagedObjectContext?) -> Object
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
    var oid: ObjectID? {
        get {
            return id
        }
        set {
            id = newValue
        }
    }
//MARK: - Entity
    func savedObject(for objectContext: NSManagedObjectContext?) -> Object? {
        guard let oid else {
            return nil
        }
        return try? Self.fetching(with: NSPredicate(format: "oid = %@", "\(oid)"), objectContext: objectContext).first
    }
    func object(for objectContext: NSManagedObjectContext?) -> Object {
        guard let objectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        return map(object: Object(context: objectContext), isUpdating: false, objectContext: objectContext)
    }
//MARK: - Writing
    func save(_ objectContext: NSManagedObjectContext? = nil) {
        guard let viewContext = objectContext ?? DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        viewContext.perform {
            do {
                if let savedObject = savedObject(for: objectContext) {
                    _ = map(object: savedObject, isUpdating: true, objectContext: objectContext)
                    try viewContext.save()
                }else {
                    _ = object(for: objectContext)
                    try viewContext.save()
                }
            }catch {
                print(error)
            }
        }
    }
    func delete(_ objectContext: NSManagedObjectContext? = nil) {
        guard let viewContext = objectContext ?? DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        viewContext.perform {
            do {
                guard let savedObject = savedObject(for: objectContext) else {return}
                viewContext.delete(savedObject)
                try viewContext.save()
            }catch {
                print(error)
            }
        }
    }
//MARK: - Fetching
    static func fetch(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = [], objectContext: NSManagedObjectContext? = nil) throws -> [Self] {
        return try fetching(with: predicate, sortDescriptors: sortDescriptors, objectContext: objectContext).model()
    }
    static func fetching(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = [], objectContext: NSManagedObjectContext? = nil) throws -> [Self.Object] {
        guard let viewContext = objectContext ?? DataConfigurations.shared.managedObjectContext else {
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
