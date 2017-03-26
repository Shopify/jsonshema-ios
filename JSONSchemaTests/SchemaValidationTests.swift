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
		let dependencies: [PropertyName: PropertyDependency<PropertyName>] = [.a: .property([.b])]
	}
	
    func testRequiredKeysValidation() {
		let schema = DummySchema()
		
		XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1")]))
		
		XCTAssertThrowsError(_ = try schema.validate(against: ["b": .string("1")]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .string(""), "b": .string("1")]))
    }
    

	func testPropertyDependenciesValidation() {
		let schema = DummySchema()
		
		XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1")]))
		
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "b": .number(0)]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1)]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "c": .number(0)]))
		XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "c": .string("1")]))		
	}
  
    

    struct SchemaDependencySchema: JSONSchemaType {
        
        struct SubSchema: JSONSchemaType {
            public typealias PropertyName = SchemaDependencySchema.PropertyName
            
            var properties: [PropertyName: JSONValueValidator] {
                return [
                    .b: string(),
                ]
            }
            let required:[PropertyName] = [.b]
        }
        
        enum PropertyName: String {
            case a
            case b
            case c
        }
        
        var properties: [PropertyName: JSONValueValidator] {
            return [
                .a: number(),
                .c: string()
            ]
        }
        let dependencies: [PropertyName: PropertyDependency<PropertyName>] = [.a: .schema(SubSchema().asExtension)]
    }
    
    func testSchemaDependenciesValidation() {
        
        let schema = SchemaDependencySchema()
        XCTAssertNoThrow(_ = try schema.validate(against: ["c": .string("1")]))
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1"), "c": .string("1")]))

        XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1)]))
        XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "b": .null, "c": .string("1")]))
        
        var validated: ValidatedJSON<SchemaDependencySchema.PropertyName>!
        XCTAssertNoThrow(validated = try schema.validate(against: ["a": .number(1), "b": .string("1"), "c": .string("1")]))
        XCTAssert(validated[.b] as? String == "1")
    }
    
    struct FailingSchema: JSONSchemaType {
        enum PropertyName: String {
            case a
        }
        
        var properties: [PropertyName: JSONValueValidator] {
            return [
                .a: number()
            ]
        }
        let required: [PropertyName]  = [.a]
        let additionalProperties: Bool = false
    }
    
    func testAdditionalProperties() {
        let schema = DummySchema()
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1")]))
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1"), "asasd": .null]))
        
        let failingSchema = FailingSchema()
        
        XCTAssertThrowsError(_ = try failingSchema.validate(against: ["a": .number(1), "asasd": .null]))

    }
    
    
    struct PatternPropertySchema: JSONSchemaType {
        enum PropertyName: String {
            case a
        }
        
        var properties: [PropertyName: JSONValueValidator] {
            return [
                .a: number()
            ]
        }
        let required: [PropertyName]  = [.a]
        var patternProperties: [PatternPropertyName: JSONValueValidator] {
            return [
                PatternPropertyName(pattern: "^S_.*"): string()
            ]
        }
        
    }
    func testPatternPropertyValidation() {
        let schema = PatternPropertySchema()
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1)]))
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "b": .string("1")]))
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "S_somethig": .string("1")]))
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "S_": .string("1")]))
        XCTAssertNoThrow(_ = try schema.validate(against: ["a": .number(1), "S_aa": .string("1")]))
        
        XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "S_somethig": .null]))
        XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "S_": .null]))
        XCTAssertThrowsError(_ = try schema.validate(against: ["a": .number(1), "S_1": .null]))
    }
}
