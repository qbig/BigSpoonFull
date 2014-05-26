//
//  DishModifierItem.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 26/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DishModifierItem : NSObject
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic) double *itemPrice;
@property (nonatomic) int *itemCount;
@end
