//
//  NSString+Eclipsize.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import "NSString+Eclipsize.h"

@implementation NSString(extendWithEclipsizeMethod)
- (NSString *) eclipsizeWithLengthLimit: (int) lengthLimit;{
    if ([self length] >= lengthLimit) {
        return [[self substringToIndex: lengthLimit - 3]stringByAppendingString:@"..."];
    } else {
        return self;
    }
}
@end
