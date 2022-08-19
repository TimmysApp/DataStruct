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
        guard let properties = try? allProperties() else {
            return object
        }
        properties.forEach { property in
            let value = property.value
            let key = dataKeys[property.key] ?? property.key
            if property.key == "oid" {
                let newValue = value as? UUID ?? UUID()
                object.setValue(newValue, forKey: property.key)
            }else if let datableValue = value as? Datable {
                if datableValue.oid == nil || oid == nil {
                    object.setValue(datableValue.object, forKey: key)
                }else {
                    object.setValue(datableValue.updatedObject, forKey: key)
                }
            }else if let datableValue = value as? Array<Datable> {
                let set = NSSet(array: datableValue.map { subValue in
                    if subValue.oid == nil || oid == nil{
                       return subValue.object
                    }
                    return subValue.updatedObject
                })
                object.setValue(set, forKey: key)
            }else {
                if let intValue = value as? Int {
                    object.setValue(intValue, forKey: key)
                }else {
                    object.setValue(value, forKey: key)
                }
            }
        }
        return object
    }
}
