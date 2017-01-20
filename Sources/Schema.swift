//
//  Schema.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-15.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation


public typealias PropertyListType = Hashable & RawRepresentable

public protocol JSONSchemaType: RootScopeValidatorsDSL,
								StringValidatorsDSL,
								CombinatoricValidatorsDSL,
								NumberValidatorsDSL,
								ArrayValidatorsDSL {
	
	associatedtype PropertyList: PropertyListType
	
	var properties: [PropertyList: JSONValueValidator] { get }
	var required: [PropertyList] { get }
	init()
}

