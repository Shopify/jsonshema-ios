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

struct AdditionalPropertiesValidationError: Error, CustomStringConvertible {
    private var propertieNames: [String]
    
    init(propertiesNames: [String]) {
        self.propertieNames = propertiesNames
    }
    
    var description: String {
        return "Additional properties that should not be present \(propertieNames.joined(separator: ","))"
    }
}


protocol PatternPropertyNameType {
    var me: PatternPropertyName { get }
}
extension PatternPropertyName: PatternPropertyNameType {
    var me: PatternPropertyName {
        return self
    }
}


extension Dictionary where Key: PatternPropertyNameType {
    func matchingPropertyNames(_ name: String) -> [(pattern: PatternPropertyName, validator: JSONValueValidator)]? {
        var result = [(pattern: PatternPropertyName, validator: JSONValueValidator)]()
        for (key, value) in self {
            if key.me.matches(name) {
                result.append((key as! PatternPropertyName, value as! JSONValueValidator))
            }
        }
        return result
    }
}


enum ExtendedPropertyName<PropertyName: PropertyNameType>: Hashable {
    case fixed(PropertyName)
    case unspecified(String)
    
    var hashValue: Int {
        switch self {
        case .fixed(let propertyName): return propertyName.hashValue
        case .unspecified(let str): return str.hashValue
        }
    }
    
    static func ==(lhs: ExtendedPropertyName, rhs: ExtendedPropertyName) -> Bool {
        switch (lhs, rhs) {
        case (.fixed(let propertyNameLeft), .fixed(let propertyNameRight)):
            return propertyNameLeft == propertyNameRight
        case (.unspecified(let strLeft), .unspecified(let strRight)):
            return strLeft == strRight
        default: return false
        }
    }
}

public struct ValidatedJSON<PropertyName: PropertyNameType>  {
    private var storage: [ExtendedPropertyName<PropertyName>: Any] = [:]
    fileprivate mutating func set(value: Any, for key: PropertyName) {
        storage[.fixed(key)] = value
    }
    fileprivate mutating func set(value: Any, for key: String) {
        storage[.unspecified(key)] = value
    }
    
    public subscript(key: PropertyName) -> Any? {
        return storage[.fixed(key)]
    }
    
    public subscript(key: String) -> Any? {
        return storage[.unspecified(key)]
    }

}

extension JSONSchemaType where PropertyName.RawValue == String {
    
    func validate(against json: JSONObject) throws -> ValidatedJSON<PropertyName> {
        var validated = ValidatedJSON<PropertyName>()
        
        var additionalProperties: [String: Any] = [:]
        
        for (key, value) in json {
            if let propertyName = PropertyName(rawValue: key),
                let validator = self.properties[propertyName] {
                do {
                    try validator(value)
                    validated.set(value: value.asRawValue(), for: propertyName)
                } catch let error {
                    throw PropertyValueValidationError(property: key, value: "\(value.asRaw())", error: error)
                }
                
            } else if let patternProperties = self.patternProperties.matchingPropertyNames(key),
                patternProperties.count > 0 {
                
                do {
                    let validators = patternProperties.map { $0.validator }
                    for validator in validators {
                        try validator(value)
                    }
                    validated.set(value: value.asRawValue(), for: key)
                } catch let error {
                    throw PropertyValueValidationError(property: key, value: "\(value.asRaw())", error: error)
                }
                
            } else {
                additionalProperties[key] = value
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
        
        if additionalProperties.count > 0 && !self.additionalProperties  {
            throw AdditionalPropertiesValidationError(propertiesNames: Array(additionalProperties.keys))
        }
        return validated
    }
}

