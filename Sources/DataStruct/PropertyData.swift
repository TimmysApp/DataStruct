//
//  File.swift
//  
//
//  Created by Joe Maghzal on 12/31/22.
//

import Foundation
import CoreData

struct PropertyData {
//MARK: - Properties
    var propertyName: String
    var propertyValue: Any
    var dataKeys: [String: String]
    var nonDataKeys: [String]
//MARK: - Functions
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
