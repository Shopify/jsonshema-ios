//
//  SchemaValidationBase.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-16.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

public typealias JSONValueValidator = (JSONValue) throws -> ()
public typealias ContentValidator<T> = (T) throws -> ()
public typealias StringValidator = ContentValidator<String>
public typealias NumberValidator = ContentValidator<NSNumber>
public typealias BoolValidator = ContentValidator<Bool>
public typealias NullValidator = ContentValidator<NSNull>
public typealias ArrayValidator = ContentValidator<[JSONValue]>
public typealias ObjectValidator = ContentValidator<JSONObject>




struct RequiredFieldsMissingError: Error, CustomStringConvertible {
    private var missingPropertyNames: [String]
    private var schemaName: String
    
    init<S: JSONSchemaType>(missingKeys: [String], for schema: S) {
        self.missingPropertyNames = missingKeys
        self.schemaName = String(reflecting: type(of: schema))
    }
    
    var description: String {
        return "Following properties defined by schema \"\(self.schemaName)\" missing: \(self.missingPropertyNames.joined(separator: ","))"
    }
}

struct PropertyValueValidationError: Error, CustomStringConvertible {
    private var propertyName: String
    private var propertyValue: String
    private var underlyingError: Error
    
    init(property: String, value: String, error: Error) {
        self.propertyName = property
        self.propertyValue = value
        self.underlyingError = error
    }
    
    var description: String {
        return "Validation failed for property for key \"\(propertyName)\" with error:\n\(self.underlyingError) \n(value: \(self.propertyValue))"
    }
}


extension JSONSchemaType where PropertyName.RawValue == String {
    
    func validate(against json: JSONObject) throws -> [PropertyName: Any] {
        var validated:[PropertyName: Any] = [:]
        
        for (key, value) in json {
            if let propertyName = PropertyName(rawValue: key),
                let validator = self.properties[propertyName] {
                do {
                    try validator(value)
                    validated[propertyName] = value.asRawValue()
                } catch let error {
                    throw PropertyValueValidationError(property: key, value: "\(value.asRaw())", error: error)
                }
                
            }
        }
        let presentKeys = Set(json.keys.map(PropertyName.init).flatMap { $0 } )
        var requiredKeys = Set(self.required)
        
        let dependencyKeys = Set(self.dependencies.keys)
        
        let keysRequiredByDependencies = dependencyKeys
            .intersection(presentKeys)
            .flatMap { self.dependencies[$0]! }
        
        requiredKeys.formUnion(keysRequiredByDependencies)
        
        if !requiredKeys.isSubset(of: presentKeys) {
            let missingKeysArray = Array(requiredKeys.subtracting(presentKeys)).map { $0.rawValue }
            throw RequiredFieldsMissingError(missingKeys: missingKeysArray, for: self)
        }
        
        return validated
    }
}

