//
//  DishModifierSection.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 27/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DishModifierItem.h"
#import "Constants.h"
@interface DishModifierSection : NSObject
@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic, strong) NSString *itemTitleDescription;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) double threshold;
@property (nonatomic, strong) NSArray *items;

- (DishModifierSection *) initWithSectionJsonDict: (NSDictionary *) dict;
- (double) getSum;
@end
