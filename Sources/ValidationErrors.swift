//
//  ValidationErrors.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-18.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

struct ValidatorTypeMismatch: Error, CustomStringConvertible {
	private var expectedType: Any.Type
	private var actualValue: Any
	
	init(expectedType: Any.Type, actualValue: Any) {
		self.expectedType = expectedType
		self.actualValue = actualValue
	}
	
	var description: String {
		return "Value \"\(self.actualValue)\" of type \(type(of: self.actualValue)) expected to have type \(self.expectedType)"
	}
}



struct PatternStringValidatorError: Error, CustomStringConvertible {
	private var value: String
	private var pattern: String
	
	init(value: String, pattern: String) {
		self.value = value
		self.pattern = pattern
	}
	
	var description: String {
		return "Value \"\(self.value)\" doesn't match pattern \"\(self.pattern)\""
	}
}

struct StringLengthValidatorError: Error, CustomStringConvertible {
	private enum Reason {
		case lessThanMin
		case greaterThanMax
	}
	
	private var reason: Reason
	private var value: String
	private var expectedLength: Int
	
	private init(value: String, expectedLength: Int, reason: Reason) {
		self.value = value
		self.expectedLength = expectedLength
		self.reason = reason
	}
	
	static func lessThan(expectedLength: Int, value: String) -> StringLengthValidatorError {
		return StringLengthValidatorError(value: value, expectedLength: expectedLength, reason: .lessThanMin)
	}
	
	static func greaterThan(expectedLength: Int, value: String) -> StringLengthValidatorError {
		return StringLengthValidatorError(value: value, expectedLength: expectedLength, reason: .greaterThanMax)
	}
	
	var description: String {
		switch self.reason {
		case .lessThanMin:
			return "Value \"\(self.value)\"'s length is less than min\(self.expectedLength)"
		case .greaterThanMax:
			return "Value \"\(self.value)\"'s length is greater than max\(self.expectedLength)"
		}
	}
}

struct NumberValidationError: Error, CustomStringConvertible {
	private let value: NSNumber
	private let required: NSNumber
	private let exclusive: Bool
	
	private enum Reason {
		case lessThanMin
		case greaterThanMax
	}
	private var reason: Reason
	
	static func lessThan(actual: NSNumber, expected: NSNumber, exclusively: Bool) -> NumberValidationError {
		return NumberValidationError(value: actual,
		                             required: expected,
		                             exclusive: exclusively,
		                             reason: .lessThanMin)
	}
	
	static func greaterThan(actual: NSNumber, expected: NSNumber, exclusively: Bool) -> NumberValidationError {
		return NumberValidationError(value: actual,
		                             required: expected,
		                             exclusive: exclusively,
		                             reason: .greaterThanMax)
	}
	
	
	var description: String {
		switch self.reason {
		case .lessThanMin:
			return "Value \(self.value) is less \(self.exclusive ? "" : "or equal") than min\(self.required)"
		case .greaterThanMax:
			return "Value \(self.value) is greater \(self.exclusive ? "" : "or equal") than max\(self.required)"
		}
	}
}

struct MultipleOfValidationError: Error, CustomStringConvertible {
	private let multiple: Int
	private let value: Int
	
	init(value: Int, multiple: Int) {
		self.value = value
		self.multiple = multiple
	}
	
	var description: String {
		return "Value \(self.value) is not a multiple of \(self.multiple)"
	}
}

struct ArrayLengthValidatorError: Error, CustomStringConvertible {
	private enum Reason {
		case lessThanMin
		case greaterThanMax
	}
	
	private var reason: Reason
	private var actualLength: Int
	private var expectedLength: Int
	
	private init(actualLength: Int, expectedLength: Int, reason: Reason) {
		self.actualLength = actualLength
		self.expectedLength = expectedLength
		self.reason = reason
	}
	
	static func lessThan(expectedLength: Int, actualLength: Int) -> ArrayLengthValidatorError {
		return ArrayLengthValidatorError(actualLength: actualLength, expectedLength: expectedLength, reason: .lessThanMin)
	}
	
	static func greaterThan(expectedLength: Int, actualLength: Int) -> ArrayLengthValidatorError {
		return ArrayLengthValidatorError(actualLength: actualLength, expectedLength: expectedLength, reason: .greaterThanMax)
	}
	
	var description: String {
		switch self.reason {
		case .lessThanMin:
			return "Array length \(self.actualLength) is less than min\(self.expectedLength)"
		case .greaterThanMax:
			return "Array length \(self.actualLength) is greater than max\(self.expectedLength)"
		}
	}
}

struct ArrayNotUnqiueError: Error, CustomStringConvertible {
	
	var description: String {
		return "Array is not unique"
	}
}


struct CombinatoricValidationError: Error, CustomStringConvertible {
	enum Reason {
		case allOfFiled
		case anyOfFailed
		case oneOfFailed
		case noneOfFailed
	}
	var reason: Reason
	var underlyingErrors: [Error]
	
	static func allOfFailed(underlying: [Error]) -> CombinatoricValidationError {
		return CombinatoricValidationError(reason: .allOfFiled, underlyingErrors: underlying)
	}
	
	static func anyOfFailed(underlying: [Error]) -> CombinatoricValidationError {
		return CombinatoricValidationError(reason: .anyOfFailed, underlyingErrors: underlying)
	}
	
	static func oneOfFailed(underlying: [Error]) -> CombinatoricValidationError {
		return CombinatoricValidationError(reason: .oneOfFailed, underlyingErrors: underlying)
	}
	
	static func noneOfFailed(underlying: [Error]) -> CombinatoricValidationError {
		return CombinatoricValidationError(reason: .noneOfFailed, underlyingErrors: underlying)
	}
	
	var description: String {
		let errorsDescription = self.underlyingErrors.map { "\($0)" }.joined(separator: ",")
		return "Combinatoric validation \(self.reason) failed with underlying errors:\n\(errorsDescription)"
	}
}
