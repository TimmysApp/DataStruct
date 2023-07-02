//
//  File.swift
//  
//
//  Created by Joe Maghzal on 23/04/2023.
//

import Foundation

@propertyWrapper
struct Mapped<T, Map> {
//MARK: - Properties
    var mapping: (T) -> Map
//MARK: - Initializer
    init(mapping: @escaping (T) -> Map, wrappedValue defaultValue: T) {
        self.mapping = mapping
        self.wrappedValue = defaultValue
    }
//MARK: - Wrapper
    var wrappedValue: T
    var projectedValue: Map {
        return mapping(wrappedValue)
    }
}
