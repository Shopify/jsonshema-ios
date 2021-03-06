//
//  Schema.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-15.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation


public typealias PropertyNameType = Hashable & RawRepresentable



public struct SchemaExtension<P: PropertyNameType>  {
    let validator: (JSONObject) throws -> ValidatedJSON<P>
    init(validator: @escaping (JSONObject) throws -> ValidatedJSON<P>)   {
        self.validator = validator
    }
}

public enum PropertyDependency<PropertyName: PropertyNameType>  {
    case property([PropertyName])
    case schema(SchemaExtension<PropertyName>)
}

public protocol JSONSchemaType: RootScopeValidatorsDSL,
    StringValidatorsDSL,
    CombinatoricValidatorsDSL,
    NumberValidatorsDSL,
ArrayValidatorsDSL {
    
    associatedtype PropertyName: PropertyNameType
    
    var properties: [PropertyName: JSONValueValidator] { get }
    var required: [PropertyName] { get }
    var dependencies: [PropertyName: PropertyDependency<PropertyName>] { get }
    var additionalProperties: Bool { get }
    var patternProperties: [PatternPropertyName: JSONValueValidator] { get }
    init()
}

extension JSONSchemaType {
    public var dependencies: [PropertyName: PropertyDependency<PropertyName>] {
        return [:]
    }
    
    var properties: [PropertyName] {
        return []
    }
    
    var required: [PropertyName] {
        return []
    }
    
    var additionalProperties: Bool {
        return true
    }
    
    var patternProperties: [PatternPropertyName: JSONValueValidator] {
        return [:]
    }
}

extension JSONSchemaType where PropertyName.RawValue == String {
    var asExtension: SchemaExtension<PropertyName> {
        return SchemaExtension(validator: self.validate(against:))
    }
}

public struct PatternPropertyName: Hashable {
    var pattern: String
    var predicate: NSPredicate
    public init(pattern: String) {
        self.pattern = pattern
        self.predicate = NSPredicate(format:"SELF MATCHES %@", pattern)
    }
    func matches(_ string: String) -> Bool {
        return predicate.evaluate(with: string)
    }
    
    public var hashValue: Int {
        return pattern.hashValue
    }
    
    static public func ==(lhs: PatternPropertyName, rhs: PatternPropertyName) -> Bool {
        return lhs.pattern == rhs.pattern
    }
}
