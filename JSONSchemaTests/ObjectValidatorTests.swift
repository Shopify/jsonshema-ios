//
//  ObjectValidatorTests.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-17.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import JSONSchema

class ObjectValidatorTests: XCTestCase,
	RootScopeValidatorsDSL,
	StringValidatorsDSL,
	CombinatoricValidatorsDSL,
	NumberValidatorsDSL,
	ArrayValidatorsDSL
{
	
	struct SubSchema: JSONSchemaType {
		enum PropertyList: String {
			case a
			case b
		}
		
		var properties: [PropertyList: JSONValueValidator] {
			return [
				.a: string(
					length(min: 1)
				),
				.b: number()
			]
		}
		
		let required: [PropertyList] = [.a, .b]
	}
	
    
    func testObjectSchemaValidation() {
		let validator = schema(SubSchema())
		XCTAssertNoThrow(try validator(["a": .string("1"), "b": .number(1)]))
		XCTAssertThrowsError(try validator(["a": .string(""), "b": .null]))
    }
    
}
