//
//  UIColor+ColorFromHex.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 27/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import "UIColor+ColorFromHex.h"

@implementation UIColor(extendWithColorFromHexMethod)
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    // bypass '#' character
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
