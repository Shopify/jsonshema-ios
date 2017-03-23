//
//  JSONTests.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-16.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import JSONSchema


class JSONTests: XCTestCase {
        
    func testJSONFromRawSuccess() {
		do {
			let _ = try JSONValue(raw:["a": 1])
			let _ = try JSONValue(raw:["a": "1"])
			let _ = try JSONValue(raw:["a": NSNull()])
			let _ = try JSONValue(raw:["a": true])
			let _ = try JSONValue(raw:["a": [1.0]])
			let _ = try JSONValue(raw:["a": []])
			let _ = try JSONValue(raw:["a": [:]])
		} catch let error {
			XCTFail("Call should not throw, cought \(error)")
		}
		
    }
	
	func testJSONFromRawFail() {
		struct SomeValueType {}

		XCTAssertThrowsError(try JSONValue(raw:["a": CGPoint.zero])) { error in
			XCTAssert(error as? JSONValueError != nil)
		}

		XCTAssertThrowsError(try JSONValue(raw:["a": [CGPoint.zero]])) { error in
			XCTAssert(error as? JSONValueError != nil)
		}
		
		XCTAssertThrowsError(try JSONValue(raw:["a": ["b": CGPoint.zero]])) { error in
			XCTAssert(error as? JSONValueError != nil)
		}


		XCTAssertThrowsError(try JSONValue(raw:["a": SomeValueType()])) { error in
			XCTAssert(error as? JSONValueError != nil)
		}
	}
	
	func testJSONValueUnwrapping() {
		
		XCTAssertEqual(JSONValue.number(1).asNumber(), 1)
		XCTAssertEqual(JSONValue.number(1).asString(), nil)
		XCTAssertEqual(JSONValue.number(1).asBool(), nil)
		XCTAssert(JSONValue.number(1).asObject() == nil)
		
		XCTAssertEqual(JSONValue.string("1").asNumber(), nil)
		XCTAssertEqual(JSONValue.string("1").asString(), "1")
		XCTAssert(JSONValue.string("1").asObject() == nil)
		
		XCTAssert(JSONValue.null.isNull())
		XCTAssertEqual(JSONValue.null.asString(), nil)
		XCTAssertEqual(JSONValue.null.asBool(), nil)
		XCTAssert(JSONValue.null.asObject() == nil)

		let arrayValue = [JSONValue.number(1)]
		
		XCTAssertEqual(JSONValue.array(arrayValue).asArray()?[0].asNumber(), 1)
		XCTAssertEqual(JSONValue.array(arrayValue).asString(), nil)
		XCTAssertEqual(JSONValue.array(arrayValue).asBool(), nil)
		XCTAssert(JSONValue.array(arrayValue).asObject() == nil)

		let objectValue = ["a": JSONValue.number(1)]

		XCTAssertEqual(JSONValue.object(objectValue).asObject()?["a"]?.asNumber(), 1)
		XCTAssertEqual(JSONValue.object(objectValue).asString(), nil)
		XCTAssertEqual(JSONValue.object(objectValue).asBool(), nil)
		XCTAssert(JSONValue.object(objectValue).asArray() == nil)

	}
	
	
}
