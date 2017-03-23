//
//  SchemaValidationTests.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-27.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import JSONSchema

class SchemaValidationTests: XCTestCase {
	
	struct DummySchema: JSONSchemaType {
		enum PropertyName: String {
			case a
			case b
			case c
		}
		
		var properties: [PropertyName: JSONValueValidator] {
			return [
				.a: number(),
				.b: string(),
				.c: string()
			]
		}
		let required: [PropertyName]  = [.a]
		let dependencies: [PropertyName: [PropertyName]] = [.a: [.b]]
	}
	
    func testRequiredKeysValidation() {
		let schema = DummySchema()
		
		XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1")]))
		
		XCTAssertThrowsError(_ = try schema.validate(against: ["b": .string("1")]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .string(""), "b": .string("1")]))
    }
    

	func testDependenciesValidation() {
		let schema = DummySchema()
		
		XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1")]))
		
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "b": .number(0)]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1)]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "c": .number(0)]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "c": .string("1")]))		
	}
}
