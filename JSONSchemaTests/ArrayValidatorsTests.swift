//
//  ArrayValidatorsTests.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-18.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import JSONSchema

class ArrayValidatorsTests: XCTestCase,
	RootScopeValidatorsDSL,
	StringValidatorsDSL,
	CombinatoricValidatorsDSL,
	NumberValidatorsDSL,
	ArrayValidatorsDSL
{
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testArrayItemsValidator() {
		
		let failingArrayValidator = items(failingJSONValueValidator)
		
		XCTAssertThrowsError(try failingArrayValidator([.null]))
		
		let nonFailingArrayValidator = items(nonFailingJSONValueValidator)
		XCTAssertNoThrow(try nonFailingArrayValidator([.null]))
		
	}
	
	func testArrayLengthValidator() {
		
	}
	
	func testArrayUniqueValidator() {
		let uniqueValidator = unique(true)
		
		
		XCTAssertNoThrow(try uniqueValidator([.null, .boolean(true)]))
		XCTAssertNoThrow(try uniqueValidator([.boolean(true), .boolean(false)]))
		XCTAssertNoThrow(try uniqueValidator([.number(1), .number(1.1), .number(2)]))
		XCTAssertNoThrow(try uniqueValidator([.string(""), .string("123")]))
		XCTAssertNoThrow(try uniqueValidator([.array([.boolean(true), .null]), .array([.null, .boolean(true)])]))
		XCTAssertNoThrow(try uniqueValidator([.array([.boolean(true)]), .array([.boolean(false)])]))
		XCTAssertNoThrow(try uniqueValidator([.object(["a": .boolean(true)]), .object(["b": .boolean(true)])]))
		XCTAssertNoThrow(try uniqueValidator([.object(["a": .boolean(true)]), .object(["a": .boolean(false)])]))
		
		
		XCTAssertThrowsError(try uniqueValidator([.null, .null]))
		XCTAssertThrowsError(try uniqueValidator([.number(1), .number(1)]))
		XCTAssertThrowsError(try uniqueValidator([.number(1), .number(1.0)]))
		XCTAssertThrowsError(try uniqueValidator([.boolean(true), .boolean(true)]))
		XCTAssertThrowsError(try uniqueValidator([.string("123"), .string("123")]))
		XCTAssertThrowsError(try uniqueValidator([.array([.boolean(true)]), .array([.boolean(true)])]))
		XCTAssertThrowsError(try uniqueValidator([
			.object([
				"a": .boolean(true),
				"b": .boolean(false)
			]),
			.object([
				"b": .boolean(false),
				"a": .boolean(true)
			])
		]))
		
	}
}
