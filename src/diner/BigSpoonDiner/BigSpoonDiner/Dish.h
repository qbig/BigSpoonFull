//
//  Dish.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dish : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) int price;
@property (nonatomic) int ratings;

- (id) initWithName: (NSString *) name Description: (NSString *) description Price: (int) price Ratings: (int) ratings;

@end
