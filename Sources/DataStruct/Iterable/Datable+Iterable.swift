//
//  File.swift
//  
//
//  Created by Joe Maghzal on 7/17/22.
//
import Foundation
import CoreData

public extension Datable {
    func map(object: Object, isUpdating: Bool, objectContext: NSManagedObjectContext?) -> Object {
        guard let properties = allProperties() else {
            return object
        }
        properties.forEach { property in
            guard !Self.nonDataKeys.contains(property.key) else {return}
            let value = property.value
            let key = Self.dataKeys[property.key] ?? property.key
            if property.key == "id" {
                object.setValue(value, forKey: "oid")
            }else {
                guard case Optional<Any>.some = property.value else {
                    object.setNilValueForKey(key)
                    return
                }
                if let datableValue = value as? (any Datable) {
                    object.setValue(isUpdating ? datableValue.savedObject: datableValue.object(for: objectContext), forKey: key)
                }else if let datableValue = value as? Array<any Datable> {
                    let array = datableValue.map { item in
                        if let saved = item.savedObject(for: objectContext) {
                            return saved
                        }
                        return item.object(for: objectContext)
                    }
                    let set = NSSet(array: array)
                    object.setValue(set, forKey: key)
                }else if let datableValue = value as? DatableValue {
                    object.setValue(datableValue.dataValue, forKey: key)
                }else if let datableValues = value as? [DatableValue] {
                    object.setValue(datableValues.map(\.dataValue), forKey: key)
                }
                else {
                    object.setValue(value, forKey: key)
                }
            }
        }
        return object
    }
}
