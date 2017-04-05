//
//  NSNumber+BoolExtraction.m
//  BuyAppCore
//
//  Created by Sergey Gavrilyuk on 2017-04-04.
//  Copyright © 2017 Shopify. All rights reserved.
//

#import "NSNumber+BoolExtraction.h"

@implementation NSNumber (BoolExtraction)
- (BOOL)isObjcBool
{
	return strcmp([self objCType], [@YES objCType]) == 0;
}
@end
