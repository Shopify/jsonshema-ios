//
//  StringValidation.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-16.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

public protocol PatternValidatorConvertible {
    var pattern: String { get }
}

public enum BuiltinStringValidatorsFormats: PatternValidatorConvertible {
    case email
    case datetime
    
    public var pattern: String {
        switch self {
        // email format regex
        case .email: return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            //datetime regex as sepcified in http://tools.ietf.org/html/rfc3339
            //unescaped \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:.\d+)?(Z|([+-]\d{2}\:\d{2}))
            // e.g. 2017-01-01T01:00:00Z
        // e.g. 2017-01-01T01:00:00.123+05:00
        case .datetime: return "\\d{4}\\-\\d{2}\\-\\d{2}T\\d{2}\\:\\d{2}\\:\\d{2}(?:\\.\\d+)?(Z|([+-]\\d{2}\\:\\d{2}))"
        }
    }
}



