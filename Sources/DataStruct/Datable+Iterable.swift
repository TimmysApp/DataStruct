//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/17/22.
//
import Foundation
import CoreData

public extension Datable {
//    static func map(from object: Object?) -> Self? {
//        var newObject = empty
//        guard let properties = try? newObject.allProperties() else {
//            return nil
//        }
//        properties.forEach { property in
//            let key = dataKeys[property.key] ?? property.key
//            let value = object?.value(forKey: key)
//            if let set = value as? NSSet,  let valueType = newObject[property.key] as? [Datable] {
//                let type = type(of: valueType).Element.s
//                let setValue = (set.allObjects as? Array<NSManagedObject>)?.compactMap({type.map(from: $0)})
//                newObject[property.key] = setValue
//            }
//        }
//        return newObject
//    }
    func getObject(from object: Object, isUpdating: Bool) -> Object {
        guard let properties = allProperties() else {
            return object
        }
        properties.map({PropertyData(propertyName: $0.key, propertyValue: $0.value, dataKeys: Self.dataKeys, nonDataKeys: Self.nonDataKeys)}).forEach { property in
            property.setProperty(from: object, isUpdating: isUpdating)
        }
        return object
    }
}
