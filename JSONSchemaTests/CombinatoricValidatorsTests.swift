//
//  CombinatoricValidatorsTests.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-17.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import JSONSchema

struct FailingValidatorError: Error {}
let failingJSONValueValidator: JSONValueValidator = {_ in
	throw FailingValidatorError()

}

let nonFailingJSONValueValidator: JSONValueValidator = {_ in
}

class CombinatoricValidatorsTests: XCTestCase,
	RootScopeValidatorsDSL,
	StringValidatorsDSL,
	CombinatoricValidatorsDSL,
	NumberValidatorsDSL,
	ArrayValidatorsDSL
{
	
	struct DummySchema: JSONSchemaType {
		enum PropertyName: String { case a }
		
		var properties: [PropertyName: JSONValueValidator] {
			return [
				
				.a: anyOf(
						number(
							value(min: 3),
							value(max: 10),
							multipleOf(2)
						),
						string(
							format(.email)
						),
						array(
							items(
								number()
							)
						)
					)
			]
		}
		let required: [PropertyName]  = [.a]
	}
	
    func testAllOfValidation() {
		let schema = DummySchema()
		
		let failingValidator = allOf(failingJSONValueValidator, nonFailingJSONValueValidator, nonFailingJSONValueValidator)
		
		XCTAssertThrowsError(try failingValidator(.null))
		let nonFailingValidator = schema.allOf(nonFailingJSONValueValidator, nonFailingJSONValueValidator)
		XCTAssertNoThrow(try nonFailingValidator(.null))
    }

	func testAnyOfValidation() {
		
		let failingValidators = [
			anyOf(failingJSONValueValidator, failingJSONValueValidator),
			anyOf(failingJSONValueValidator)
		]
		for failingValidator in failingValidators {
			XCTAssertThrowsError(try failingValidator(.null))
		}
		
		let nonFailingValidator = anyOf(failingJSONValueValidator, failingJSONValueValidator, nonFailingJSONValueValidator)
		XCTAssertNoThrow(try nonFailingValidator(.null))
	}

	
	func testOneOfValidation() {
		
		let failingValidators = [
			oneOf(nonFailingJSONValueValidator, nonFailingJSONValueValidator, failingJSONValueValidator),
			oneOf(failingJSONValueValidator),
			oneOf()
		]
		for failingValidator in failingValidators{
			XCTAssertThrowsError(try failingValidator(.null))
		}
		let nonFailingValidators = [
			oneOf(failingJSONValueValidator, failingJSONValueValidator, nonFailingJSONValueValidator),
			oneOf(nonFailingJSONValueValidator)
		]
		
		for nonFailingValidator in nonFailingValidators {
			XCTAssertNoThrow(try nonFailingValidator(.null))
		}
	}

	func testNoneOfValidation() {
		
		let failingValidators = [
			noneOf(nonFailingJSONValueValidator, failingJSONValueValidator, failingJSONValueValidator),
			noneOf(nonFailingJSONValueValidator)
		]
		
		for failingValidator in failingValidators {
			XCTAssertThrowsError(try failingValidator(.null))
		}
		let nonFailingValidators = [
			noneOf(failingJSONValueValidator, failingJSONValueValidator, failingJSONValueValidator),
			noneOf(failingJSONValueValidator, failingJSONValueValidator),
			noneOf(failingJSONValueValidator),
			noneOf()
		]

		for nonFailingValidator in nonFailingValidators {
			XCTAssertNoThrow(try nonFailingValidator( .null))
		}
	}

}
