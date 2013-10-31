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

- (void) addDish: (Dish *) dish;
- (void) minusDish: (Dish *) dish;

- (int) getQuantityOfDish: (Dish *) dish;
- (int) getQuantityOfDishID: (int) dishID;
- (int) getTotalQuantity;
- (int) getTotalPrice;
- (void) mergeWithAnotherOrder: (Order *)newOrder;
- (int) getNumberOfDishes;

@end
