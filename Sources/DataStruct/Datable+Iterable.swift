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
//            if property.key == "id" {
//                let newValue = value as? UUID ?? UUID()
//                object.setValue(newValue, forKey: "oid")
//            }else if let datableValue = value as? (any Datable) {
//                object.setValue(isUpdating ? datableValue.updatedObject: datableValue.object, forKey: key)
//            }else if let datableValue = value as? Array<any Datable> {
//                let set = NSSet(array: datableValue.map({isUpdating ? $0.updatedObject: object}))
//                object.setValue(set, forKey: key)
//            }else if let datableValue = value as? DatableValue {
//                object.setValue(datableValue.dataValue, forKey: key)
//            }else if let iterableValue = value as? Iterable {
//                iterableValue.allProperties()?.forEach { iterableProperty in
//
//                }
//            }else {
//                object.setValue(value, forKey: key)
//            }
        }
        return object
    }
}

struct PropertyData {
    var propertyName: String
    var propertyValue: Any
    var dataKeys: [String: String]
    var nonDataKeys: [String]
    func setProperty(from object: NSManagedObject, isUpdating: Bool) {
        guard !nonDataKeys.contains(propertyName) else {return}
        let value = propertyValue
        let key = dataKeys[propertyName] ?? propertyName
        if key == "id" {
            let newValue = value as? UUID ?? UUID()
            object.setValue(newValue, forKey: "oid")
        }else if let datableValue = value as? (any Datable) {
            object.setValue(isUpdating ? datableValue.updatedObject: datableValue.object, forKey: key)
        }else if let datableValue = value as? Array<any Datable> {
            let set = NSSet(array: datableValue.map({isUpdating ? $0.updatedObject: object}))
            object.setValue(set, forKey: key)
        }else if let datableValue = value as? DatableValue {
            object.setValue(datableValue.dataValue, forKey: key)
        }else if let iterableValue = value as? Iterable {
            iterableValue.allProperties()?.map({PropertyData(propertyName: $0.key, propertyValue: $0.value, dataKeys: type(of: iterableValue).dataKeys, nonDataKeys: type(of: iterableValue).nonDataKeys)}).forEach { iterableProperty in
                iterableProperty.setProperty(from: object, isUpdating: isUpdating)
            }
        }else {
            object.setValue(value, forKey: key)
        }

    }
}
