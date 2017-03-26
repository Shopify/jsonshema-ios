//
//  TypeValidatorsTests.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-17.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import JSONSchema

func XCTAssertNoThrow(_ expression: @autoclosure () throws -> (), file: StaticString = #file, line: UInt = #line) {
	do {
		try expression()
    } catch let e { XCTFail("\(e)", file: file, line: line) }
}

class TypeValidatorsTests: XCTestCase,
	RootScopeValidatorsDSL,
	StringValidatorsDSL,
	CombinatoricValidatorsDSL,
	NumberValidatorsDSL,
	ArrayValidatorsDSL
{
        
    func testStringTypeValidator() {
		
		let validator = string()
		
		XCTAssertNoThrow(try validator(.string("123")))
		
		XCTAssertThrowsError(try validator(.number(1)))
		XCTAssertThrowsError(try validator(.null))
		XCTAssertThrowsError(try validator(.boolean(true)))
		XCTAssertThrowsError(try validator(.array([])))
		XCTAssertThrowsError(try validator(.object([:])))
    }
	
	func testStringLengthValidator() {
		let validator: StringValidator = length(min: 2, max: 3)
		
		XCTAssertNoThrow(try validator("12"))
		XCTAssertNoThrow(try validator("123"))
		
		XCTAssertThrowsError(try validator(""))
		XCTAssertThrowsError(try validator("1"))
		XCTAssertThrowsError(try validator("123123"))
	}
	
	func testStringPatternValidator() {
		let validator = pattern("\\d{1,2}")
		
		XCTAssertNoThrow(try validator("1"))
		XCTAssertNoThrow(try validator("13"))
		
		XCTAssertThrowsError(try validator("1123"))
		XCTAssertThrowsError(try validator(""))
		XCTAssertThrowsError(try validator("asdsad"))
		
	}
	
	func testStringEmailFormatValidator() {
		let emailValidator = format(.email)
		
		XCTAssertNoThrow(try emailValidator("someone@google.com"))
		XCTAssertNoThrow(try emailValidator("someone@shopify.ca"))
		
		XCTAssertThrowsError(try emailValidator("1123"))
		XCTAssertThrowsError(try emailValidator(""))
		XCTAssertThrowsError(try emailValidator("asdsad"))
		XCTAssertThrowsError(try emailValidator("someone@s.a"))
		XCTAssertThrowsError(try emailValidator("asdsad@"))
	}
	
	func testDateTimeFormatValidator() {
		let dateValidator = format(.datetime)
		
		XCTAssertNoThrow(try dateValidator("1970-01-01T00:00:00.234+00:00"))
		XCTAssertNoThrow(try dateValidator("1997-07-16T19:20:30+01:00"))
		XCTAssertNoThrow(try dateValidator("1997-07-16T19:20:30Z"))
		XCTAssertNoThrow(try dateValidator("1997-07-16T19:20:30.123Z"))
		
		XCTAssertThrowsError(try dateValidator("1123"))
		XCTAssertThrowsError(try dateValidator(""))
		XCTAssertThrowsError(try dateValidator("asdsad"))
		XCTAssertThrowsError(try dateValidator("1997-07-16 19:20:30.45+01:00"))
		XCTAssertThrowsError(try dateValidator("1997-07-16T19:20:30.45"))
		XCTAssertThrowsError(try dateValidator("1997-07-16 19:20:30.45"))
		XCTAssertThrowsError(try dateValidator("1997-07-16T19:20:30.123Z34"))
	}
	
	
	func testNumberTypeValidator() {
		
		let validator = number()

		XCTAssertNoThrow(try validator(.number(0)))
		
		XCTAssertThrowsError(try validator(.string("1")))
		XCTAssertThrowsError(try validator(.null))
		XCTAssertThrowsError(try validator(.boolean(true)))
		XCTAssertThrowsError(try validator(.array([])))
		XCTAssertThrowsError(try validator(.object([:])))
	}
	
	func testNumberRangeValidator() {
		let validator = value(min: 10, exclusiveMin: false, max: 100)
		
		XCTAssertNoThrow(try validator(11))
		XCTAssertNoThrow(try validator(55))
		XCTAssertNoThrow(try validator(100))
		
		XCTAssertThrowsError(try validator(0))
		XCTAssertThrowsError(try validator(9))
		XCTAssertThrowsError(try validator(10))
		XCTAssertThrowsError(try validator(101))
		XCTAssertThrowsError(try validator(11000))
		
	}
	
	func testMultipleOfValidator() {
		let validator = multipleOf(10)
		XCTAssertNoThrow(try validator(10))
		XCTAssertNoThrow(try validator(20))
		
		XCTAssertThrowsError(try validator(21))
		XCTAssertThrowsError(try validator(2.1))
		
	}
	
	func testObjectValidator() {
		let validator = object()
		XCTAssertNoThrow(try validator(.object([:])))
		
		XCTAssertThrowsError(try validator(.string("1")))
		XCTAssertThrowsError(try validator(.null))
		XCTAssertThrowsError(try validator(.boolean(true)))
		XCTAssertThrowsError(try validator(.array([])))
		XCTAssertThrowsError(try validator(.number(1)))
	}
	
	func testArrayTypeValidator() {
		let validator = array()
		
		XCTAssertNoThrow(try validator(.array([])))
		
		XCTAssertThrowsError(try validator(.string("1")))
		XCTAssertThrowsError(try validator(.null))
		XCTAssertThrowsError(try validator(.boolean(true)))
		XCTAssertThrowsError(try validator(.object([:])))
		XCTAssertThrowsError(try validator(.number(1)))
	}
	
	
	func testEnumValidator() {
		let validator = string( `enum`(["1", "2", "3"]))
		
		XCTAssertNoThrow(try validator(.string("1") ))

		XCTAssertThrowsError(try validator(.string("0")))
		XCTAssertThrowsError(try validator(.null))

	}

}
