//
//  NSString+Eclipsize.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(extendWithEclipsizeMethod)
- (NSString *) eclipsizeWithLengthLimit: (int) lengthLimit;
@end
