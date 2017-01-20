//
//  JSON.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-15.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation


public typealias JSONObject = [String: JSONValue]

public enum JSONValue {
	case string(String)
	case null
	case number(NSNumber)
	case boolean(Bool)
	case object(JSONObject)
	case array([JSONValue])
}

public protocol JSONValueType {
	func asNumber() -> NSNumber?
	func asString() -> String?
	func asObject() -> JSONObject?
	func isNull() -> Bool
	func asBool() -> Bool?
	func asArray() -> [JSONValue]?
	
	func asRaw() -> Any
}

extension JSONValue: JSONValueType {
	
	func asType<T>(_ type: T.Type) -> T? {
		let (value, actualType) = self.asRaw()
		return (actualType.self == T.self) ? value as? T : nil
	}
	
	public func asBool() -> Bool? {
		return asType(Bool.self)
	}

	public func asNumber() -> NSNumber? {
		return asType(NSNumber.self)
	}
	
	public func asString() -> String? {
		return asType(String.self)
	}

	public func isNull() -> Bool {
		return asType(NSNull.self) != nil
	}

	public func asArray() -> [JSONValue]? {
		return asType([JSONValue].self)
	}
	
	public func asObject() -> JSONObject? {
		return asType(JSONObject.self)
	}
	
	public func asRaw() -> Any {
		return asRaw().value
	}
	
	
	public func asRaw() -> (value: Any, type: Any.Type) {
		switch self {
		case .string(let str): return (str, String.self)
		case .number(let num): return (num, NSNumber.self)
		case .array(let arr): return (arr, [JSONValue].self)
		case .object(let obj): return (obj, JSONObject.self)
		case .boolean(let b): return (b, Bool.self)
		case .null: return (NSNull(), NSNull.self)
		}
	}
	
}

extension JSONValue: Equatable {
	public static func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
		switch (lhs, rhs) {
			case (.null, .null): return true
			case (.boolean(let left), .boolean(let right)): return left == right
			case (.number(let left), .number(let right)): return left == right
			case (.string(let left), .string(let right)): return left == right
			case (.array(let left), .array(let right)): return left == right
			case (.object(let left), .object(let right)): return left == right
			default: return false
		}
	}
}

extension JSONValue: Hashable {
	public var hashValue: Int {
		switch self {
		case .null: return 0
		case .boolean(let b): return b.hashValue
		case .number(let num): return num.hashValue
		case .string(let str): return str.hashValue
		case .array(let arr): return arr.count
		case .object(let obj): return obj.count
		}
	}
}

private protocol StringType {}

public protocol JSONKeyType: Hashable {
	var toString: String { get }
}
extension String: JSONKeyType {
	public var toString: String { return self }
}

public struct JSONValueError: Error, CustomDebugStringConvertible {
	private var key: String? = nil
	private var value: Any
	
	init(value: Any) {
		self.value = value
	}
	
	init(value: Any, for key: String) {
		self.key = key
		self.value = value
	}
	
	public var debugDescription: String {
		if let key = self.key {
			return "Value for key \"\(key)\" does not appear to be JSON value: \(value) (type: \(type(of: value)))"
		} else {
			return "Value does not appear to be JSON value: \(value) (type: \(type(of: value)))"
		}
	}
}

extension JSONValue {
	public init(raw: Any) throws {
		if let str = raw as? String {
			self = .string(str)
		} else if let number = raw as? NSNumber {
			self = .number(number)
		} else if let bool = raw as? Bool {
			self = .boolean(bool)
		} else if let rawObject = raw as? [String: Any] {
			self = try .object(JSONObject(raw: rawObject))
		} else if let rawArray = raw as? Array<Any> {
			self = try .array(rawArray.map { try JSONValue(raw: $0) })
		} else if raw is NSNull {
			self = .null
		} else {
			throw JSONValueError(value: raw)
		}
	}
}

extension Dictionary where Key: JSONKeyType, Value: JSONValueType {
	public init(raw: [Key: Any]) throws {
		self.init()
		for (key, value) in raw {
			do {
				let jsonValue = try JSONValue(raw: value)
				self[key] = jsonValue as? Value
			} catch  {
				throw JSONValueError(value: value, for: key.toString)
			}
		}
	}

}

