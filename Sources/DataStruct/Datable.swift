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
    static var empty: Self {get}
//MARK: - Mapping
    static func map(from object: Object?) -> Self?
    func getObject(from object: Object, isUpdating: Bool) -> Object
//MARK: - Fetching
    static var modelData: ModelData<Self> {get}
}

public extension Datable {
//MARK: - Mapping
    var oid: UUID? {
        get {
            return id
        }
        set {
            id = newValue
        }
    }
    static func latestObject(for id: UUID?) -> Object? {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        guard let fetchRequest = Object.fetchRequest() as? NSFetchRequest<Object>, let id = id else {
            return nil
        }
        fetchRequest.predicate = NSPredicate(format: "oid = %@", "\(id)")
        guard let object = try? viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }//
//MARK: - Entity
    var updatedObject: Object {
        return self.getObject(from: Self.latestObject(for: self.oid) ?? Object(), isUpdating: true)
    }
    var object: Object {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        
        var newObject = self
        newObject.oid = nil
        return newObject.getObject(from: Object(context: viewContext), isUpdating: false)
    }
//MARK: - Writing
    func save() {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        _ = object
        do {
            try viewContext.save()
        }catch {
            print(String(describing: error))
        }
    }
    func update() {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        viewContext.perform {
            do {
                guard let oid = oid else {return}
                guard var toUpdate = Self.latestObject(for: oid) else {return}
                toUpdate = getObject(from: toUpdate, isUpdating: true)
                try viewContext.save()
            }catch {
                print(String(describing: error))
            }
        }
    }
    func delete() {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        do {
            guard let oid = oid else {return}
            guard let toUpdate = Self.latestObject(for: oid) else {return}
            viewContext.delete(toUpdate)
            try viewContext.save()
        }catch {
            print(String(describing: error))
        }
    }
//MARK: - Fetching
    static func rawFetch(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) throws -> [Self] {
        guard let viewContext = DataConfigurations.shared.managedObjectContext else {
            fatalError("You should set the ViewContext of the Configurations using Configurations.setObjectContext")
        }
        guard let fetchRequest = Object.fetchRequest() as? NSFetchRequest<Object> else {
            throw CoreDataStructError.invalidRequest
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        let object = try viewContext.fetch(fetchRequest)
        return object.model()
    }
    static func fetch(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = []) -> [Self] {
        do {
            return try rawFetch(with: predicate, sortDescriptors: sortDescriptors)
        }catch {
            DataConfigurations.shared.errorsPublisher.send(error)
            return []
        }
    }
}

public extension Array where Element: NSManagedObject {
    func model<T: Datable>() -> [T] {
        return self.compactMap({T.map(from: $0 as? T.Object)})
    }
}

public extension NSSet {
    func model<T: Datable>() -> [T] {
        return self.compactMap({T.map(from: $0 as? T.Object)})
    }
}

enum CoreDataStructError: Error {
    case invalidRequest
}
