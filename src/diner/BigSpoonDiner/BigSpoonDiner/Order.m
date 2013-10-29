//
//  order.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Order.h"

@interface Order ()

@property (nonatomic, strong) NSMutableArray *dishes;
@property (nonatomic, strong) NSMutableArray *quantity;

@end

@implementation Order

- (id) init{
    self = [super init];
    if (self) {
        // Initialization code
        self.dishes = [[NSMutableArray alloc] init];
        self.quantity = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addDish: (Dish *) dish{
    // If added before, just update its index:
    if ([self.dishes containsObject:dish]) {
        
        int index = [self getIndexOfDish:dish];
        int quantity = [self getQuantityOfDish:dish];
        
        NSNumber *newQuantity = [NSNumber numberWithInt: quantity + 1];
        [self.quantity setObject:newQuantity atIndexedSubscript: index];
        
    }
    
    // If it's new, add it:
    else{
        [self.dishes addObject: dish];
        [self.quantity addObject: [NSNumber numberWithInt:1]];
    }
}

- (void) minusDish:(Dish *)dish{
    if ([self.dishes containsObject:dish]) {
        
        int index = [self getIndexOfDish:dish];
        int quantity = [self getQuantityOfDish:dish];
        NSNumber* quantityObject = [self getQuantityObjectOfDish:dish];
        
        // Still have more than one quantity, just decrease the number:
        if (quantity > 1) {
            NSNumber *newQuantity = [NSNumber numberWithInt: quantity - 1];
            [self.quantity setObject:newQuantity atIndexedSubscript: index];
        }
        
        // Have less than one quantity, if minus, becomes 0 quantity, so just remove it:
        else{
            [self.quantity removeObject: quantityObject];
            [self.dishes removeObject:dish];
        }
        
    }
}

- (int) getQuantityOfDish: (Dish *) dish{
    NSNumber *quantity = [self getQuantityObjectOfDish:dish];
    return quantity.integerValue;
}

- (NSNumber *) getQuantityObjectOfDish: (Dish *) dish{
    int index = [self getIndexOfDish:dish];
    return (NSNumber *)[self.quantity objectAtIndex: index];
}

- (int) getTotalQuantity{
    int totalQuantity = 0;
    
    for (NSNumber *n in self.quantity) {
        totalQuantity += [n integerValue];
    }
    
    return totalQuantity;
}

- (int) getIndexOfDish: (Dish *) dish{
    return [self.dishes indexOfObject:dish];
}

@end
