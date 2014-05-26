//
//  DishModifier.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 26/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DishModifier : NSObject
@property (nonatomic, strong) NSString *backgroundColor;
@property (nonatomic, strong) NSString *itemTitleColor;
@property (nonatomic, strong) NSString *itemTextColor;
@property (nonatomic, strong) NSArray *modifierSections;

- (void) initWithJsonDictionary: (NSDictionary *) dict;
@end
