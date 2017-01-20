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
		self.schemaName = "\(type(of: schema))"
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


extension JSONSchemaType where PropertyList.RawValue == String {
	
	func validate(against json: JSONObject) throws -> [PropertyList: Any] {
		var validated:[PropertyList: Any] = [:]
		
		for (key, value) in json {
			if let propertyName = PropertyList(rawValue: key),
				let validator = self.properties[propertyName] {
				do {
					try validator(value)
					validated[propertyName] = value.asRaw()
				} catch let error {
					throw PropertyValueValidationError(property: key, value: "\(value.asRaw())", error: error)
				}
				
			}
		}
		let presentKeys = Set(json.keys.map(PropertyList.init).flatMap { $0 } )
		let requiredKeys = Set(self.required)
		if !requiredKeys.isSubset(of: presentKeys) {
			let missingKeysArray = Array(requiredKeys.subtracting(presentKeys)).map { $0.rawValue }
			throw RequiredFieldsMissingError(missingKeys: missingKeysArray, for: self)
		}
		return validated
	}
}

