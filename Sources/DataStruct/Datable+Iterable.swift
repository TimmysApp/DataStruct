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
        properties.forEach { property in
            guard !Self.nonDataKeys.contains(property.key) else {return}
            let value = property.value
            let key = Self.dataKeys[property.key] ?? property.key
            if property.key == "id" {
                let newValue = value as? UUID ?? UUID()
                object.setValue(newValue, forKey: "oid")
            }else {
                guard case Optional<Any>.some = property.value else {
                    object.setNilValueForKey(key)
                    return
                }
                if let datableValue = value as? (any Datable) {
                    object.setValue(isUpdating ? datableValue.updatedObject: datableValue.object, forKey: key)
                }else if let datableValue = value as? Array<any Datable> {
                    let set = NSSet(array: datableValue.map({isUpdating ? $0.updatedObject: object}))
                    object.setValue(set, forKey: key)
                }else if let datableValue = value as? DatableValue {
                    object.setValue(datableValue.dataValue, forKey: key)
                }else {
                    object.setValue(value, forKey: key)
                }
            }
        }
        return object
    }
}
