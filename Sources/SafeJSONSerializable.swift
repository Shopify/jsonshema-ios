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
    
    /*
     Entry point to deserialize from validation json data
     
     This method called after validation has completed successfully.
     Raw JSON data has been unwrapped from `JSONValue` and you can safely force-cast it expected type.
     You are expected to construct your model object from validated json data.
     
     - Note: keys in the json dictionary has been replaced with values of `PropertyName` that you implementation provided.
     - Note: values are only unwrapped at first level of nestness, which means `JSONValue` containing array or object and unwrapped recursively.
     
     - Parameters:
     - json: validated and unwrapped json data; keys replaced with `PropertyName`, values and primitive types
     
     - Returns desereialized model object.
     
     - Throws: deserizliation of nested objects may follow it's own schema validatio, that in turn can throw.
     */
    static func fromValidatedJSON(json: [Schema.PropertyName: Any]) throws -> Self
}


extension SafeJSONSerializable where Schema.PropertyName.RawValue == String {
    
    /*
     Deserialize object from given raw json data with schema validation.
     
     Performs Schema validation and if data is confirmed shcema-valid, unwraps json data to primitive types and invokes `fromValidatedJSON`
     to complete deserialization.
     
     - Parameters:
     
     - json: raw JSON object.
     
     - Throws: Any Validation error that may arise.
     
     */
    public static func fromJSON(json: JSONObject) throws -> Self {
        let schema = Schema()
        let validated = try schema.validate(against: json)
        return try fromValidatedJSON(json: validated)
    }
    
    
}
