//
//  order.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dish.h"

@interface Order : NSObject

@property (nonatomic, strong) NSMutableArray *dishes;
@property (nonatomic, strong) NSMutableArray *quantity;

// Note: In self.dishes, object equlity is NOT assumed, for example:
// You shall NEVER use:
// - [self.dishes containsObject: newDish]
// - [self.dishes indexOf: newDish]
// - [self.dishes removeObject: newDish]

- (void) addDish: (Dish *) dish;
- (void) minusDish: (Dish *) dish;

- (int) getQuantityOfDishByDish: (Dish *) dish;
- (int) getQuantityOfDishByID: (int) dishID;

- (int) getTotalQuantity;
- (int) getTotalPrice;

- (void) mergeWithAnotherOrder: (Order *)newOrder;

- (int) getNumberOfKindsOfDishes;

@end
