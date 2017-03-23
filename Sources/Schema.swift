//
//  Schema.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-15.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation


public typealias PropertyNameType = Hashable & RawRepresentable

public protocol JSONSchemaType: RootScopeValidatorsDSL,
    StringValidatorsDSL,
    CombinatoricValidatorsDSL,
    NumberValidatorsDSL,
ArrayValidatorsDSL {
    
    associatedtype PropertyName: PropertyNameType
    
    var properties: [PropertyName: JSONValueValidator] { get }
    var required: [PropertyName] { get }
    var dependencies: [PropertyName: [PropertyName]] { get }
    init()
}

extension JSONSchemaType {
    public var dependencies: [PropertyName: [PropertyName]] {
        return [:]
    }
}

