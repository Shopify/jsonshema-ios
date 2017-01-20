//
//  StringValidation.swift
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-01-16.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation



public enum BuiltinStringValidatorsFormats {
	case email
	case datetime
	
	var pattern: String {
		switch self {
		case .email: return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
		case .datetime: return "\\d{4}\\-\\d{2}\\-\\d{2}T\\d{2}\\:\\d{2}\\:\\d{2}(?:\\.\\d+)?(Z|([+-]\\d{2}\\:\\d{2}))"
		}
	}
}



