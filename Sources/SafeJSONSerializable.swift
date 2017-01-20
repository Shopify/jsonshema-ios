//
//  SafeJSONSerializable.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-16.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

public protocol SafeJSONSerializable {
	associatedtype Schema: JSONSchemaType
	
	static func fromValidatedJSON(json: [Schema.PropertyList: Any]) throws -> Self
}


extension SafeJSONSerializable where Schema.PropertyList.RawValue == String {
	static func fromJSON(json: JSONObject) throws -> Self {
		let schema = Schema()
		let validated = try schema.validate(against: json)
		return try fromValidatedJSON(json: validated)
	}
	
	
}
