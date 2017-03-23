//
//  SchemaDSL.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-15.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

public protocol RootScopeValidatorsDSL {}

extension RootScopeValidatorsDSL {
    
    private func scoped<T>(to type: T.Type, validating validators: [ContentValidator<T>] = []) -> JSONValueValidator {
        return { value in
            if let unwrappedCast = value.asType(T.self) {
                for validator in validators {
                    try validator(unwrappedCast)
                }
            } else {
                throw ValidatorTypeMismatch(expectedType: T.self, actualValue: value)
            }
        }
    }
    
    public func null() -> JSONValueValidator {
        return scoped(to: NSNull.self)
    }
    
    public func number(_ validators: NumberValidator...) -> JSONValueValidator {
        return scoped(to: NSNumber.self, validating: validators)
    }
    
    public func string(_ validators: StringValidator...) -> JSONValueValidator {
        return scoped(to: String.self, validating: validators)
    }
    
    public func bool() -> JSONValueValidator {
        return scoped(to: Bool.self)
    }
    
    public func object() -> JSONValueValidator {
        return scoped(to: JSONObject.self)
    }
    
    public func object(_ validators: ObjectValidator...) -> JSONValueValidator {
        return scoped(to: JSONObject.self, validating: validators)
    }
    
    public func array(_ validators: ArrayValidator...) -> JSONValueValidator {
        return scoped(to: [JSONValue].self, validating: validators)
    }
    
    public func schema<S: JSONSchemaType>(_ schema: S) -> ObjectValidator
        where S.PropertyName.RawValue == String {
            
            return { object in
                _ = try schema.validate(against: object)
            }
    }
    
    public func `enum`<T: Comparable & Hashable>(_ values: [T]) -> ContentValidator<T> {
        return { value in
            let expectedSet = Set(values)
            if !expectedSet.contains(value) {
                throw EnumerationValidationError(value: value, expectedValues: values)
            }
        }
    }
    
}

public protocol StringValidatorsDSL {}

extension StringValidatorsDSL {
    
    public func format(_ patternConvertible: PatternValidatorConvertible) -> StringValidator {
        return pattern(patternConvertible.pattern)
    }
    
    
    public func format(_ builtInFormat: BuiltinStringValidatorsFormats) -> StringValidator {
        return format(builtInFormat as PatternValidatorConvertible)
    }
    
    public func pattern(_ pattern: String) -> StringValidator {
        let predicate = NSPredicate(format:"SELF MATCHES %@", pattern)
        return { value in
            if !predicate.evaluate(with: value) {
                throw PatternStringValidatorError(value: value, pattern: pattern)
            }
        }
    }
    
    public func length(min: Int = 0, max: Int = Int.max) -> StringValidator {
        return { value in
            if value.characters.count < min {
                throw StringLengthValidatorError.lessThan(expectedLength: min, value: value)
            }
            if value.characters.count > max {
                throw StringLengthValidatorError.greaterThan(expectedLength: max, value: value)
            }
        }
    }
}

public protocol NumberValidatorsDSL {}

extension NumberValidatorsDSL {
    
    public func value(min: Int = Int.min, exclusiveMin:Bool = true, max: Int = Int.max, exclusiveMax: Bool = true) -> NumberValidator {
        return { value in
            if (exclusiveMin ? value.doubleValue < Double(min) : value.doubleValue <= Double(min))  {
                throw NumberValidationError.lessThan(actual: value, expected: NSNumber(value: min), exclusively: exclusiveMin)
            } else if (exclusiveMax ? value.doubleValue > Double(max) : value.doubleValue >= Double(max))  {
                throw NumberValidationError.greaterThan(actual: value, expected: NSNumber(value: max), exclusively: exclusiveMax)
            }
        }
    }
    
    public func multipleOf(_ multipleOf: Int) -> NumberValidator {
        return { value in
            guard
                value.floatValue.remainder(dividingBy: 1) == 0,
                value.intValue % multipleOf == 0
                else {
                    throw MultipleOfValidationError(value: value.intValue, multiple: multipleOf)
            }
        }
    }
}

public protocol ArrayValidatorsDSL{}
extension ArrayValidatorsDSL {
    
    
    public func items(_ itemsValidator: @escaping JSONValueValidator) -> ArrayValidator {
        return { value in
            for item in value {
                try itemsValidator(item)
            }
        }
    }
    
    public func length(min: Int, max: Int) -> ArrayValidator {
        return { value in
            if value.count < min {
                throw ArrayLengthValidatorError.lessThan(expectedLength: min, actualLength: value.count)
            } else if value.count > max {
                throw ArrayLengthValidatorError.greaterThan(expectedLength: max, actualLength: value.count)
            }
        }
    }
    
    public func unique(_ unique: Bool = true) -> ArrayValidator {
        return { value in
            if (unique) {
                let set = Set(value)
                if set.count < value.count {
                    throw ArrayNotUnqiueError()
                }
            }
        }
    }
}



public protocol CombinatoricValidatorsDSL {}

extension CombinatoricValidatorsDSL {
    
    private func evaluate<T>(value: T, validators: [ContentValidator<T>]) -> [Error] {
        var errors: [Error] = []
        for validator in validators {
            do {
                try validator(value)
            } catch let error {
                errors.append(error)
            }
        }
        return errors
    }
    
    
    public func allOf<T>(_ validators: [ContentValidator<T>]) -> ContentValidator<T> {
        if (validators.count == 1) {
            return validators[0]
        }
        
        return { value in
            let errors = self.evaluate(value: value, validators: validators)
            if errors.count > 0 {
                throw CombinatoricValidationError.allOfFailed(underlying: errors)
            }
        }
        
    }
    
    public func allOf<T>(_ validators: ContentValidator<T>...) -> ContentValidator<T> {
        return allOf(validators)
    }
    
    public func anyOf<T>(_ validators: [ContentValidator<T>]) -> ContentValidator<T> {
        if (validators.count == 1) {
            return validators[0]
        }
        
        return { value in
            let errors = self.evaluate(value: value, validators: validators)
            if errors.count == validators.count {
                throw CombinatoricValidationError.anyOfFailed(underlying: errors)
            }
        }
    }
    
    public func anyOf<T>(_ validators: ContentValidator<T>...) -> ContentValidator<T> {
        return anyOf(validators)
    }
    
    public func oneOf<T>(_ validators: [ContentValidator<T>]) -> ContentValidator<T> {
        if (validators.count == 1) {
            return validators[0]
        }
        
        return { value in
            let errors = self.evaluate(value: value, validators: validators)
            if validators.count - errors.count != 1 {
                throw CombinatoricValidationError.oneOfFailed(underlying: errors)
            }
        }
    }
    public func oneOf<T>(_ validators: ContentValidator<T>...) -> ContentValidator<T> {
        return oneOf(validators)
    }
    
    public func noneOf<T>(_ validators: [ContentValidator<T>]) -> ContentValidator<T> {
        return { value in
            let errors = self.evaluate(value: value, validators: validators)
            if validators.count != errors.count  {
                throw CombinatoricValidationError.noneOfFailed(underlying: errors)
            }
        }
    }
    public func noneOf<T>(_ validators: ContentValidator<T>...) -> ContentValidator<T> {
        return noneOf(validators)
    }
}



